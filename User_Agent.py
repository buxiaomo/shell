from user_agents import parse
import json



for line in open("1509296736_1227.json"):
    # print (line,)
    s =json.loads(line)
    # print()


    # ua_string = 'Mozilla/5.0 zgrab/0.x'
    user_agent = parse(s['result']['http_user_agent'])
    Browser = user_agent.browser.family
    System = user_agent.os.family
    Device = user_agent.device.family
    if user_agent.is_mobile :
        Type = "Mobile Phone"
    elif user_agent.is_tablet:
        Type = "Tablet PC"
    elif user_agent.is_pc:
        Type = "Computer"
    print("""%s\t%s\t%s\t%s\t%s""" % \
          (Device, System, Browser,Type, s['result']['http_user_agent']))
