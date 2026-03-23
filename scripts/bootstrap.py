#!/usr/bin/env python3
from __future__ import annotations

import argparse
import os
import platform
import shutil
import subprocess
import sys
from pathlib import Path
from typing import Iterable

ROOT = Path(__file__).resolve().parent.parent

PACKAGE_MAP = {
    "docker": {
        "apt": ["sudo", "apt-get", "install", "-y", "docker.io", "docker-compose-plugin"],
        "dnf": ["sudo", "dnf", "install", "-y", "docker", "docker-compose-plugin"],
        "yum": ["sudo", "yum", "install", "-y", "docker", "docker-compose-plugin"],
        "zypper": ["sudo", "zypper", "install", "-y", "docker", "docker-compose"],
        "brew": ["brew", "install", "docker", "docker-compose"],
        "winget": ["winget", "install", "-e", "--id", "Docker.DockerDesktop"],
        "choco": ["choco", "install", "docker-desktop", "-y"],
    },
    "helm": {
        "apt": ["sudo", "snap", "install", "helm", "--classic"],
        "dnf": ["sudo", "dnf", "install", "-y", "helm"],
        "yum": ["sudo", "yum", "install", "-y", "helm"],
        "zypper": ["sudo", "zypper", "install", "-y", "helm"],
        "brew": ["brew", "install", "helm"],
        "winget": ["winget", "install", "-e", "--id", "Helm.Helm"],
        "choco": ["choco", "install", "kubernetes-helm", "-y"],
    },
    "kubectl": {
        "apt": ["sudo", "snap", "install", "kubectl", "--classic"],
        "dnf": ["sudo", "dnf", "install", "-y", "kubectl"],
        "yum": ["sudo", "yum", "install", "-y", "kubectl"],
        "zypper": ["sudo", "zypper", "install", "-y", "kubectl"],
        "brew": ["brew", "install", "kubectl"],
        "winget": ["winget", "install", "-e", "--id", "Kubernetes.kubectl"],
        "choco": ["choco", "install", "kubernetes-cli", "-y"],
    },
    "terraform": {
        "apt": ["sudo", "snap", "install", "terraform", "--classic"],
        "dnf": ["sudo", "dnf", "install", "-y", "terraform"],
        "yum": ["sudo", "yum", "install", "-y", "terraform"],
        "zypper": ["sudo", "zypper", "install", "-y", "terraform"],
        "brew": ["brew", "install", "terraform"],
        "winget": ["winget", "install", "-e", "--id", "Hashicorp.Terraform"],
        "choco": ["choco", "install", "terraform", "-y"],
    },
    "aws": {
        "apt": ["sudo", "snap", "install", "aws-cli", "--classic"],
        "dnf": ["sudo", "dnf", "install", "-y", "awscli2"],
        "yum": ["sudo", "yum", "install", "-y", "awscli"],
        "zypper": ["sudo", "zypper", "install", "-y", "aws-cli"],
        "brew": ["brew", "install", "awscli"],
        "winget": ["winget", "install", "-e", "--id", "Amazon.AWSCLI"],
        "choco": ["choco", "install", "awscli", "-y"],
    },
    "gcloud": {
        "brew": ["brew", "install", "--cask", "google-cloud-sdk"],
        "winget": ["winget", "install", "-e", "--id", "Google.CloudSDK"],
        "choco": ["choco", "install", "gcloudsdk", "-y"],
    },
    "az": {
        "brew": ["brew", "install", "azure-cli"],
        "winget": ["winget", "install", "-e", "--id", "Microsoft.AzureCLI"],
        "choco": ["choco", "install", "azure-cli", "-y"],
    },
}

REQUIRED_TOOLS = {
    "local": ["docker", "helm"],
    "aws": ["terraform", "kubectl", "helm", "aws"],
    "gcp": ["terraform", "kubectl", "helm", "gcloud"],
    "azure": ["terraform", "kubectl", "helm", "az"],
}


def run(cmd: Iterable[str], cwd: Path | None = None) -> None:
    print("[bootstrap] $", " ".join(cmd))
    subprocess.run(list(cmd), cwd=str(cwd) if cwd else None, check=True)


def detect_package_manager() -> str | None:
    for manager in ("apt", "dnf", "yum", "zypper", "brew", "winget", "choco"):
        if shutil.which(manager):
            return manager
    return None


def detect_linux_distribution() -> str:
    os_release = Path("/etc/os-release")
    if not os_release.exists():
        return "unknown"
    data = os_release.read_text().lower()
    if "ubuntu" in data or "debian" in data:
        return "debian-family"
    if "rhel" in data or "centos" in data or "fedora" in data or "rocky" in data or "alma" in data:
        return "redhat-family"
    return "other-linux"


def ensure_tools(target: str, auto_install: bool) -> None:
    package_manager = detect_package_manager()
    print(f"[bootstrap] detected platform={platform.system().lower()} distro={detect_linux_distribution()} package_manager={package_manager}")
    for tool in REQUIRED_TOOLS[target]:
        binary = tool
        if tool == "gcloud":
            binary = "gcloud"
        if shutil.which(binary):
            continue
        if not auto_install:
            raise SystemExit(f"Missing required tool: {tool}. Re-run with --auto-install to attempt installation.")
        if package_manager is None or package_manager not in PACKAGE_MAP.get(tool, {}):
            raise SystemExit(f"Missing required tool: {tool}. No supported automatic install path for package manager '{package_manager}'.")
        run(PACKAGE_MAP[tool][package_manager])


def bootstrap_local() -> None:
    ensure_tools("local", auto_install=args.auto_install)
    run(["docker", "compose", "up", "-d"], cwd=ROOT)
    print("[bootstrap] local stack started. web=http://localhost:3001 api=http://localhost:3000 mailpit=http://localhost:8025")


def bootstrap_cloud(target: str) -> None:
    ensure_tools(target, auto_install=args.auto_install)
    tf_dir = ROOT / "infra" / "terraform" / target
    run(["terraform", "init"], cwd=tf_dir)
    run(["terraform", "apply", "-auto-approve"], cwd=tf_dir)

    if target == "aws":
        cluster_name = subprocess.check_output(["terraform", "output", "-raw", "cluster_name"], cwd=tf_dir, text=True).strip()
        region = subprocess.check_output(["terraform", "output", "-raw", "region"], cwd=tf_dir, text=True).strip()
        run(["aws", "eks", "update-kubeconfig", "--name", cluster_name, "--region", region])
    elif target == "gcp":
        cluster_name = subprocess.check_output(["terraform", "output", "-raw", "cluster_name"], cwd=tf_dir, text=True).strip()
        region = subprocess.check_output(["terraform", "output", "-raw", "region"], cwd=tf_dir, text=True).strip()
        project_id = subprocess.check_output(["terraform", "output", "-raw", "project_id"], cwd=tf_dir, text=True).strip()
        run(["gcloud", "container", "clusters", "get-credentials", cluster_name, "--region", region, "--project", project_id])
    elif target == "azure":
        cluster_name = subprocess.check_output(["terraform", "output", "-raw", "cluster_name"], cwd=tf_dir, text=True).strip()
        resource_group = subprocess.check_output(["terraform", "output", "-raw", "resource_group_name"], cwd=tf_dir, text=True).strip()
        run(["az", "aks", "get-credentials", "--name", cluster_name, "--resource-group", resource_group, "--overwrite-existing"])

    run(["helm", "upgrade", "--install", "aiclod", str(ROOT / "deploy" / "helm" / "aiclod"), "--namespace", "aiclod", "--create-namespace"])
    print(f"[bootstrap] cloud deployment completed for target={target}")


parser = argparse.ArgumentParser(description="One-click bootstrap for AiClod")
parser.add_argument("--target", choices=["local", "aws", "gcp", "azure"], default="local")
parser.add_argument("--auto-install", action="store_true", default=True, help="Attempt to install missing prerequisites automatically")
parser.add_argument("--no-auto-install", dest="auto_install", action="store_false")
args = parser.parse_args()

if args.target == "local":
    bootstrap_local()
else:
    bootstrap_cloud(args.target)
