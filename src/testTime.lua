local tab = {}
for i=1, 100 do
	table.insert(tab, os.time())
end
ngx.say("testTime")

