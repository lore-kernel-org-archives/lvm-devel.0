From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 21 Oct 2011 13:14:23 +0200
Subject: [PATCH] Add configure option to select default run directory base and prepare for early /run use
In-Reply-To: <4EA14FA2.9030705@redhat.com>
References: <4EA1404A.5020500@redhat.com> <4EA14FA2.9030705@redhat.com>
Message-ID: <4EA1540F.6060802@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/21/2011 12:55 PM, Zdenek Kabelac wrote:
> Dne 21.10.2011 11:50, Peter Rajnoha napsal(a):
>>  AH_TEMPLATE(DEFAULT_RUN_DIR, [Name of default run directory.])
>>  AC_ARG_WITH(default-run-dir,
>> -	    [  --with-default-run-dir=DIR       Default run directory [[/var/run/lvm]] ],
>> +	    [  --with-default-run-dir=DIR       Default run directory [[RDIR/lvm]] ],
>>  	    [ DEFAULT_RUN_DIR="$withval" ],
>> -	    [ DEFAULT_RUN_DIR="/var/run/lvm" ])
>> +	    [ DEFAULT_RUN_DIR="$DEFAULT_RUN_DIR_BASE/lvm" ])
>>  AC_DEFINE_UNQUOTED(DEFAULT_RUN_DIR,["$DEFAULT_RUN_DIR"] )
>>  
> 
> 
> I guess we should stay with just one place to configure /var/run
> 
> So I'd replace DEFAULT_RUN_DIR usage in the code  with  DEFAULT_RUN_DIR/lvm
> and use just this define.

That's an option as well. Depends on whether we're OK with redefining it this
way... but yes, I'd say it can't do any harm.

Peter


