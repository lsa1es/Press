#!/usr/bin/python
# coding: utf-8
# Luiz Sales - luiz.sales@servicemonit.com.br
# ServiceMonit

from zabbix_api import ZabbixAPI

zapi = ZabbixAPI(server="http://caminho-do-seu-zabbix")
zapi.login("login","pass")

grupos = zapi.hostgroup.get({"output": "extend"})
for q in grupos:
    GroupID = q[u'groupid']
    GroupName = q[u'name']
    print "Grupo: %s " % (GroupName)
    hosts = zapi.host.get({"output": "extend", "selectInterfaces": "extend", "groupids" : GroupID})
    for w in hosts:
        HostID = w[u'hostid']
        HostName = w[u'name']
        HostHost = w[u'host']
        print "HostHost: %s , HostName: %s " % (HostHost,HostName)
        HostsInterfaces = w[u'interfaces']
        items = zapi.item.get({"output": "extend", "hostids": HostID})
        for r in items:
            ItemID = r[u'itemid']
            ItemName = r[u'name']
            ItemKey_ = r[u'key_']
            ItemLastValue = r[u'lastvalue']
            triggers = zapi.trigger.get({"output": "extend", "expandDescription": "extend", "itemids" : ItemID})
            print "ItemName: %s , ItemKey_: %s , ItemLastValue: %s " % (ItemName,ItemKey_,ItemLastValue)
            if triggers:
                for t in triggers:
                    TriggerStatus = t[u'status']
                    TriggerName = t[u'description']
                    TriggerPriority = t[u'priority']
                    if TriggerStatus == '0':
                        print "TriggerName: %s , TriggerSeveridade: %s " % (TriggerName,TriggerPriority)
            print
        print
    print
