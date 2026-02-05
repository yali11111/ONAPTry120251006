# ONAP VNF Onboarding Tools

VNF onboarding is an industry-wide challenge due to the lack of a standardized VNF format.
This project provides tooling and automation to simplify and standardize onboarding of
ONAP-compatible VNFs.

## Project Goals

- Reduce the effort and time required to onboard VNFs into ONAP
- Enable early validation of ONAP compatibility in vendor CI/CD pipelines
- Improve VNF quality and consistency through automated testing

## Key Components

### CI/CD Integration
Reusable CI/CD components that vendors can integrate into their pipelines to:
- Package VNFs into ONAP-ready artifacts
- Generate required metadata and descriptors
- Run automated validation checks

### Validation Framework
Automated validation tools that perform:
- Schema validation of VNF descriptors
- Compliance checks against ONAP requirements
- Best-practice and policy enforcement

### Testing Framework
Automated tests to verify:
- VNF lifecycle operations (instantiate, scale, heal, terminate)
- Deployability in ONAP environments
- Integration with ONAP components

## Getting Started

### Prerequisites
- Python 3.9+
- Docker
- Access to an ONAP environment (optional for full integration tests)

### Run Validation Locally
```bash
python validation/validate.py examples/sample-vnf/
CI/CD Usage
Example CI/CD templates are provided for:
    • GitHub Actions
    • GitLab CI
    • Jenkins
See the ci-cd/ directory for details.
Documentation
    • Architecture Overview
    • Onboarding Workflow
Contributing
Contributions are welcome! Please see CONTRIBUTING.md.