From: Milan Broz <mbroz@redhat.com>
Date: Wed, 08 Apr 2009 12:50:47 +0200
Subject: [PATCH v2] Enable use of cached metadata for pvs & pvdisplay
In-Reply-To: <49DC3F7C.1030006@redhat.com>
References: <49D9E6F4.90205@redhat.com> <49DB3352.1060909@redhat.com>
	<49DC3F7C.1030006@redhat.com>
Message-ID: <49DC8187.1070104@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Takahiro Yasui wrote:
>> @@ -778,12 +785,19 @@ int process_each_pv(struct cmd_context *cmd, int argc, char **argv,
>>  				if (ret > ret_max)
>>  					ret_max = ret;
>>  				if (sigint_caught())
>> -					return ret_max;
>> +					goto bad;
> 
> In the above line, "goto bad" is typo of "goto out"?

hm. you are right, I thought that signal interruption should return ECMD_FAIL but apparently
reporting code do not use that.

We should probably define something like ECMD_INTERRUPTED and use that... but it is unrelated problem.


If Alasdair acks that, I fix it in real commit.

Milan


