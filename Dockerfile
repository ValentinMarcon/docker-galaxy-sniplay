# SNiPlay Workflow Galaxy container
#
# Galaxy - sniplay3_complete_workflow
# Galaxy - haplotype_analysis_workflow
#
# Version 0.2 
#
# From Björn A. Grüning galaxy docker image
FROM bgruening/galaxy-stable

MAINTAINER Valentin Marcon, valentin.marcon@inra.fr
MAINTAINER Alexis Dereeper, alexis.deeepeer@ird.fr

# Tool conf that remove not used tools for Sniplay
ADD src/cfg/tool_conf.xml $GALAXY_ROOT/config/

# Install the sniplay3_complete_workflow
ADD src/cfg/my_tool_list.yml $GALAXY_ROOT/my_tool_list.yml
RUN install-tools $GALAXY_ROOT/my_tool_list.yml

# Add the visualizations plugin of sniplay
ADD src/cfg/sniplayvisu $GALAXY_ROOT/config/plugins/visualizations/sniplayvisu

#ENV GALAXY_CONFIG_TOOL_PATH=/galaxy-central/tools/

# Mark folders as imported from the host.
VOLUME ["/export/", "/data/", "/var/lib/docker"]

# Expose port 80 (webserver), 21 (FTP server), 8800 (Proxy)
EXPOSE :80
EXPOSE :21
EXPOSE :8800

# Install the workflow
RUN mkdir -p $GALAXY_HOME/workflows
ADD src/cfg/Galaxy-Workflow-SNiPlay.ga $GALAXY_HOME/workflows/ 
ADD src/cfg/Galaxy-Workflow-Haplotype_analysis.ga $GALAXY_HOME/workflows/
ADD src/cfg/Galaxy-Workflow-SNiPlay3_GWAS.ga $GALAXY_HOME/workflows/
RUN startup_lite && \
    galaxy-wait && \
    workflow-install --workflow_path $GALAXY_HOME/workflows/ -g http://localhost:8080 -u $GALAXY_DEFAULT_ADMIN_USER -p $GALAXY_DEFAULT_ADMIN_PASSWORD

# Container Style for Sniplay/Southgreen
ADD src/img/welcome_image_snip.png $GALAXY_CONFIG_DIR/web/welcome_image_snip.png
ADD src/web/welcome.html $GALAXY_CONFIG_DIR/web/welcome.html

# Autostart script that is invoked during container start
CMD ["/usr/bin/startup"]
