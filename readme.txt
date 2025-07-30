## Author: Preethi Salian(p-salian@ti.com)##


* All of the 3 scripts use the url to connect to the naps API.
"https://naps.itg.ti.com/winauthwebservices/api/v1/secrets/<secret-id>/fields/password"


* The SDK Client is installed on the server LEWVCMDB and is initialized to access the service account "ent\sccmpvreader" directly from naps API.

* During the initialization process, we provide SDK Key and the SDK Name.
SDK Key: RuN6/on2MiGthkrAxz606lvMCQ1zR6+1Z9Lh+75TeS0=
SDK Name: SDK-SCCM

* Below are the commands used to initialize and fetch the password for "ent\sccmpvreader" account.
Tss init --url https://naps.itg.ti.com/ -r SDK-SCCM -k RuN6/on2MiGthkrAxz606lvMCQ1zR6+1Z9Lh+75TeS0=
Tss secret -s 246177 -f password

For the purpose of masking the SDK key and name, we have added it in the environment variables and used the same variable in the script.

* Once the "ent\sccmpvreader" password is accessed, it is then used to access the naps API to fetch other service account passwords for each domain.
