PCM XML Generator little README


Required Packages (script will install these if you do not already have them):
- XML
- rjson
- hash
- RCurl

Execution:
Rscript pcm-xml-generator.R breast.hashed.RData

The first (and only) accepted argument is a path to an RData file.  This file should contain objects in a format identical to the provided example.

Workflow:

1. Determine if file exists
2. Determine if packages are installed
	- If not, install them
	- I would suggest modifying line 19 of the script with the appropriate mirror for your location
3. Load RData file into "inputData" environment
4. Loop through objects and construct output XML
	- This script makes GET requests against 'http://rest.genenames.org/fetch/symbol/{$symbol}' to fetch HGNC ID's
	- The first execution will take ~5 minutes (on my work iMac, at least) while these queries are made
	- Once execution is completed, an internal map of Gene Symbols -> Gene IDs is cached as a ".rds" file.  This file is referenced on subsequent executions to speed things up.
	- The birthdate value is randomly generated on execution time


Please contact me at daniel.p.carbone@vanderbilt.edu if you run into any issues
