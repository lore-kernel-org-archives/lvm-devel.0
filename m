From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 25 Jul 2013 11:17:27 +0200
Subject: master - cleanup: lvm complient style
In-Reply-To: <51F056EA.3010403@redhat.com>
References: <20130722104212.0008361478@fedorahosted.org>
	<51F056EA.3010403@redhat.com>
Message-ID: <51F0ED27.70308@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25.7.2013 00:36, Tony Asleson napsal(a):
> On 07/22/2013 05:42 AM, Zdenek Kabelac wrote:
>> Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d4ad728610db1751af1eab2c8c7d6130a3742394
>> Commit:        d4ad728610db1751af1eab2c8c7d6130a3742394
>> Parent:        05a70f2da306164f3c604c50d69e74090b0028bc
>> Author:        Zdenek Kabelac <zkabelac@redhat.com>
>> AuthorDate:    Fri Jul 19 15:33:26 2013 +0200
>> Committer:     Zdenek Kabelac <zkabelac@redhat.com>
>> CommitterDate: Mon Jul 22 12:41:21 2013 +0200
>>
>> cleanup: lvm complient style
>>
>> drop unused assignments.
>
> ...
>
>>   		/* Each call to PyModule_AddObject decrefs it; compensate: */
>> -		Py_INCREF(LibLVMError);
>> -		Py_INCREF(LibLVMError);
>> -		PyModule_AddObject(m, "error", LibLVMError);
>> -		PyModule_AddObject(m, "LibLVMError", LibLVMError);
>> +		Py_INCREF(_LibLVMError);
>> +		Py_INCREF(_LibLVMError);
>> +		PyModule_AddObject(m, "error", _LibLVMError);
>> +		PyModule_AddObject(m, "_LibLVMError", _LibLVMError);
>
> This changed the visible exception from LibLVMError to _LibLVMError
> which breaks existing python code.
>

Ahhh my bad - find&replace - and I've missed  "" around.
I'll commit fix.

Zdenek




