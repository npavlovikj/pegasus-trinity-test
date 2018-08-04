#!/bin/bash

set -e

# create dax file
./dax.py > pipeline.dax

# create the site catalog
cat > sites.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<sitecatalog xmlns="http://pegasus.isi.edu/schema/sitecatalog" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://pegasus.isi.edu/schema/sitecatalog http://pegasus.isi.edu/schema/sc-4.0.xsd" version="4.0">

    <site  handle="local" arch="x86_64" os="LINUX">
        <directory type="shared-scratch" path="/work/deogun/npavlovikj/MIRA/Pegasus_Code/trinity/work">
            <file-server operation="all" url="file:///work/deogun/npavlovikj/MIRA/Pegasus_Code/trinity/work"/>
        </directory>
        <directory type="local-storage" path="/work/deogun/npavlovikj/MIRA/Pegasus_Code/trinity/scratch">
            <file-server operation="all" url="file:///work/deogun/npavlovikj/MIRA/Pegasus_Code/trinity/scratch"/>
        </directory>
    </site>

    <site  handle="local-tusker" arch="x86_64" os="LINUX">
        <directory type="shared-scratch" path="/work/deogun/npavlovikj/MIRA/Pegasus_Code/trinity/out">
            <file-server operation="all" url="file:///work/deogun/npavlovikj/MIRA/Pegasus_Code/trinity/out"/>
        </directory>
        <profile namespace="pegasus" key="style">glite</profile>
        <profile namespace="condor" key="grid_resource">batch slurm</profile>
        <profile namespace="pegasus" key="queue">batch</profile>
        <profile namespace="env" key="PEGASUS_HOME">/usr</profile>
        <profile namespace="env" key="PERL5LIB">/util/opt/anaconda/deployed-conda-envs/packages/trinity/envs/trinity-2.4.0/lib/perl5</profile>
    </site>

</sitecatalog>
EOF

# plan and submit the workflow
pegasus-plan --conf pegasusrc --sites local-tusker --output-site local --dir /work/deogun/npavlovikj/MIRA/Pegasus_Code/trinity --dax pipeline.dax --submit
