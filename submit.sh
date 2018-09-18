#!/bin/bash

# request_memory is in MBs, the default is 1 GB
# maxwalltime is in minutes, the default is 1 hour

set -e

# create dax file
./dax.py > pipeline.dax

# create the site catalog
cat > sites.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<sitecatalog xmlns="http://pegasus.isi.edu/schema/sitecatalog" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://pegasus.isi.edu/schema/sitecatalog http://pegasus.isi.edu/schema/sc-4.0.xsd" version="4.0">

    <site  handle="local" arch="x86_64" os="LINUX">
        <directory type="shared-scratch" path="${PWD}/work">
            <file-server operation="all" url="file://${PWD}/work"/>
        </directory>
        <directory type="local-storage" path="${PWD}/scratch">
            <file-server operation="all" url="file://${PWD}/scratch"/>
        </directory>
    </site>

    <site  handle="local-hcc" arch="x86_64" os="LINUX">
        <directory type="shared-scratch" path="${PWD}/out">
            <file-server operation="all" url="file://${PWD}/out"/>
        </directory>
        <profile namespace="pegasus" key="style">glite</profile>
        <profile namespace="condor" key="grid_resource">batch slurm</profile>
        <profile namespace="pegasus" key="queue">batch</profile>
        <profile namespace="env" key="PEGASUS_HOME">/usr</profile>
        <profile namespace="condor" key="request_memory">3000</profile>
        <profile namespace="globus" key="maxwalltime">120</profile>
        <profile namespace="env" key="PERL5LIB">/util/opt/anaconda/deployed-conda-envs/packages/trinity/envs/trinity-2.4.0/lib/perl5</profile>
    </site>

</sitecatalog>
EOF

# plan and submit the workflow
pegasus-plan --conf pegasusrc --sites local-hcc --output-site local --dir ${PWD} --dax pipeline.dax --submit
