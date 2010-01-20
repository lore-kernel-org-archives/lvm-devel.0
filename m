From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 20 Jan 2010 13:53:51 +0100
Subject: [PATCH] dmeventd coredump fix
In-Reply-To: <4B5065D4.10108@redhat.com>
References: <4B4EDBDF.7070509@redhat.com> <4B5065D4.10108@redhat.com>
Message-ID: <4B56FCDF.3060207@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 15.1.2010 13:55, Zdenek Kabelac napsal(a):
> Dne 14.1.2010 09:54, Zdenek Kabelac napsal(a):
>> Hi
>>
>> I've noticed that on my test machine dmeventd generates quite often weird
>> coredumps with somewhat strange backtraces.
>>
>> Thus I've searched for the reason and with valgrind trace I've noticed
>> problem with  struct cmdline_context _cmdline
>>
>> Thread 2:
>> Conditional jump or move depends on uninitialised value(s)
>>    at 0x4C9B826: free (vg_replace_malloc.c:325)
>>    by 0x751C86F: lvm_fin (lvmcmdline.c:1213)
>>    by 0x7537ACC: lvm2_exit (lvmcmdlib.c:116)
>>    by 0x7365BEE: unregister_device (dmeventd_mirror.c:316)
>>    by 0x804AAFE: _monitor_unregister (dmeventd.c:664)
>>    by 0x804B853: _monitor_thread (dmeventd.c:805)
>>    by 0x4CBC584: start_thread (pthread_create.c:300)
>>    by 0x6EA426D: clone (clone.S:130)
>>
>> Invalid free() / delete / delete[]
>>    at 0x4C9B866: free (vg_replace_malloc.c:325)
>>    by 0x751C86F: lvm_fin (lvmcmdline.c:1213)
>>    by 0x7537ACC: lvm2_exit (lvmcmdlib.c:116)
>>    by 0x7365BEE: unregister_device (dmeventd_mirror.c:316)
>>    by 0x804AAFE: _monitor_unregister (dmeventd.c:664)
>>    by 0x804B853: _monitor_thread (dmeventd.c:805)
>>    by 0x4CBC584: start_thread (pthread_create.c:300)
>>    by 0x6EA426D: clone (clone.S:130)
>> Address 0x51 is not stack'd, malloc'd or (recently) free'd
>>
>> Crash seems to appear when mirror device is reregistered during our test suit.
>> Not really sure if it's related to some other reported problems.
>>
>> Basically we need to clear commands_size & num_commands and
>> it doesn't matter if it is in init or finish -
>>
>> I'm proposing this oneline patch:
>>
>> --- tools/lvmcmdline.c	11 Jan 2010 19:19:17 -0000	1.111
>> +++ tools/lvmcmdline.c	14 Jan 2010 08:33:50 -0000
>>  -1192,6 +1192,7 @@ struct cmd_context *init_lvm(void)
>>  {
>>  	struct cmd_context *cmd;
>>
>> +	memset(&_cmdline, 0, sizeof(_cmdline));
>>  	_cmdline.the_args = &_the_args[0];
>>
>>  	if (!(cmd = create_toolcontext(0, NULL)))
>>
> 
> Ok - patch above has some problems with order of calling lvm2_init() calls;
> 
> So here comes simpler version which only clears structure elements right after
> they are being released:
> 
> --- tools/lvmcmdline.c	11 Jan 2010 19:19:17 -0000	1.111
> +++ tools/lvmcmdline.c	15 Jan 2010 12:51:58 -0000
> @@ -1213,6 +1213,10 @@ static void _fin_commands(void)
>  		dm_free(_cmdline.commands[i].valid_args);
> 
>  	dm_free(_cmdline.commands);
> +
> +	_cmdline.commands = NULL;
> +	_cmdline.num_commands = 0;
> +	_cmdline.commands_size = 0;
>  }
> 
>  void lvm_fin(struct cmd_context *cmd)

Issue is now being tracked at:

https://bugzilla.redhat.com/show_bug.cgi?id=557104

Zdenek




