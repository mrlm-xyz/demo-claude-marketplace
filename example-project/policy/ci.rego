package main

# policy-as-code: rules the CI workflow itself must satisfy, enforced with
# conftest in the pipeline. Governance lives in version control, not in a wiki.

# Deny a workflow that grants broad write permissions by default.
deny contains msg if {
	input.permissions.contents == "write"
	msg := "ci must not default to contents: write; grant least privilege per job"
}

# Deny any deploy that skips the security scan.
deny contains msg if {
	some job
	input.jobs[job].needs
	not contains_security_scan(input.jobs[job].needs)
	endswith(job, "deploy")
	msg := sprintf("deploy job %q must depend on security-scan", [job])
}

contains_security_scan(needs) if {
	some i
	needs[i] == "security-scan"
}
