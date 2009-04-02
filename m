From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 02 Apr 2009 17:21:15 -0400
Subject: Re: [RFC PATCH 0/7] Introduce metadata cache feature
In-Reply-To: <20090402201311.GA8492@redhat.com>
References: <49D4F38B.9090705@redhat.com> <20090402201311.GA8492@redhat.com>
Message-ID: <49D52C4B.9010209@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Mike Snitzer wrote:
 >> FUTURE WORKS
>> ============
> ...
>> * Add commandline option
>>
>>   Add a new commandline option (ex --metadatacache y|n) to enable and
>>   disable cache feature in order to override a setting of the lvm
>>   configuration file.
> 
> You should already be able to achieve that with:
> 
> <lvm_command> ... --config 'backup{metadata_cache=1}'
> or
> <lvm_command> ... --config 'backup{metadata_cache=0}'

Unfortunately another parse procedure in _gets_settings() is needed
to handle the command line option, since metadata_cache option in
lvm.conf is processed in init_lvm() before a command line option is
parsed in lvm_run_command().

But thank you for the suggestion. Command line '--config' option
should be handled as well. I will update this in the next version.

Thanks,
Taka


