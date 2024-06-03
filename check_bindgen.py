#!/bin/env python3
from packaging.version import Version
import argparse


def main():
    parser = argparse.ArgumentParser(description='Compare input version with a reference.')
    parser.add_argument('version', type=str, help='The version to compare')
    args = parser.parse_args()
    if Version(args.version) >= Version('0.61.0'):
        print("bindgen-cli")
    else:
        print("bindgen")


if __name__ == '__main__':
    main()