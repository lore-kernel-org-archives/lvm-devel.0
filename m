From: Petr Rockai <prockai@redhat.com>
Date: Thu, 21 Oct 2010 18:38:39 +0200
Subject: [PATCH 4/4] Update tests for lvseg apis.
In-Reply-To: <4CBEDBCE.1060400@redhat.com> (Zdenek Kabelac's message of "Wed, 
	20 Oct 2010 14:08:46 +0200")
References: <1287494696-18310-1-git-send-email-dwysocha@redhat.com>
	<1287494696-18310-5-git-send-email-dwysocha@redhat.com>
	<4CBEDBCE.1060400@redhat.com>
Message-ID: <87zku75wmo.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:
> Dne 19.10.2010 15:24, Dave Wysochanski napsal(a):
>> diff --git a/test/api/test.c b/test/api/test.c
>> index fea3d0d..20f4210 100644
>> --- a/test/api/test.c
>> +++ b/test/api/test.c
>> @@ -69,6 +69,8 @@ static void _show_help(void)
>>  	       "List the PVs that exist in VG vgname\n");
>>  	printf("'vg_list_lvs vgname': "
>>  	       "List the LVs that exist in VG vgname\n");
>> +	printf("'lv_list_lvsegs vgname lvname': "
>> +	       "List the LV segments that exist in LV vgname/lvname\n");
>>  	printf("'vgs_open': "
>>  	       "List the VGs that are currently open\n");
>>  	printf("'vgs': "
>> @@ -569,12 +571,15 @@ static void _vg_tag(char **argv, int argc, int add)
>>  	       add ? "adding":"removing", argv[2], argv[1]);
>>  }
>>  
>> -static void _print_property_value(struct lvm_property_value value)
>> +static void _print_property_value(const char *name,
>> +				  struct lvm_property_value v)

> const struct if you do not modify it.
Whether or not you modify it, the change cannot be reflected in the
caller. This is call by value.

> And I think using pointer would be wise decision here.
Care to elaborate? What's wise about using a pointer here?


