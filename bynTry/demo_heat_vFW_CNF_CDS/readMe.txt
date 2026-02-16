demo/heat/vFW_CNF_CDS/
├── automation/                # Automation scripts (Python)
│   ├── config.py              # Environment & parameters
│   ├── instantiation.py       # Instantiates the CNF
│   ├── onboarding.py          # Onboarding helpers
│   ├── create_cloud_regions.py# Optional cloud region automation
│   └── … (pipenv files, utils)
├── templates/                 # Helm/manifest templates
│   ├── helm/                  # CNF Helm charts
│   │   ├── base_template/     # Base Helm chart
│   │   ├── vpkg/              # vFW package chart
│   │   └── … 
│   ├── package_native/        # Native Helm onboarding package
│   ├── package_dummy/         # Dummy Heat version (deprecated)
│   └── Makefile               # Builds onboarding ZIPs
└── README / manifest files
```
