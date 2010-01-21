From: Milan Broz <mbroz@redhat.com>
Date: Thu, 21 Jan 2010 18:38:13 +0100
Subject: [PATCH] Do not print "-1" as locking type if locking fails.
In-Reply-To: <1264094603.4120.3.camel@f10-node1>
References: <1264091865-4776-1-git-send-email-mbroz@redhat.com>
	<1264094603.4120.3.camel@f10-node1>
Message-ID: <4B589105.6060508@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/21/2010 06:23 PM, Dave Wysochanski wrote:
>> @@ -249,8 +251,10 @@ int init_locking(int type, struct cmd_context *cmd)
>>  		}
>>  		if (!find_config_tree_int(cmd, "locking/fallback_to_clustered_locking",
>>  			    find_config_tree_int(cmd, "global/fallback_to_clustered_locking",
>> -						 DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING)))
>> +						 DEFAULT_FALLBACK_TO_CLUSTERED_LOCKING))) {
>> +			log_error("External locking initialisation failed.");
>>  			break;
>> +		}
>>  #endif
> 
> This looks strange and inconsistent with the rest of the code.
> IMO the message be directly under the above code when
> init_external_locking() fails, as the others are.

yes. because there is quiet fallback to internal cluster locking, I think it should not print
error when fallback to internal locking succeeded.
(I think there are many RHEL4 configuration set to locking type 2 still)

Milan


