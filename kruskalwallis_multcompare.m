conditions = fieldnames(projectresults.conditions);
areas = regexp(projectresults.areas,',','split');
table = [];
table_det1 = [];
table_det2 = [];
for i=1:length(conditions)
cond = conditions{i};
for j=1:length(areas)
area = areas{j};
len = length(projectresults.conditions.(cond).regions.areas.(area).segments_supra);
table = [table; projectresults.conditions.(cond).regions.areas.(area).segments_supra repmat(j,len,1)];
table_det1 = [table_det1; repmat({cond},len,1)];
table_det2 = [table_det2; repmat({area},len,1)];
end
end
table_det = [table_det1 table_det2];

for i=1:length(table_det)
table_deta{i}=[table_det{i,1} table_det{i,2}];
end
[p, table,stats] = kruskalwallis(table(:,1),table_deta);
multcompare(stats)
[c,m,h,gnames] = multcompare(stats)