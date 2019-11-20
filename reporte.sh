docker-compose exec sonarqube java -jar /opt/sonarqube/extensions/plugins/sonar-cnes-report-3.1.0.jar -e -f -m -o /data/reports -r /data/template/code-analysis-template.docx -p LevelWeb
