import requests,json
# Send_Log_To_Splunk('xxx.xxx.xxx','xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx', json.dumps(i))
def Send_Log_To_Splunk(Domain,Auth,TXT):
    url="http://%s:8088/services/collector/event" % (Domain)
    headers = {
        'Authorization': 'Splunk %s' % (Auth)
    }
    payload={}
    payload['event'] = TXT
    response = requests.request("POST", url, data=json.dumps(payload), headers=headers)
    print(response.text)
