From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 22 Sep 2011 18:06:56 +0200
Subject: [PATCH 0/3] Clvmd -E fixes
In-Reply-To: <4E7B5B97.9020703@redhat.com>
References: <cover.1316684951.git.zkabelac@redhat.com>
	<4E7B5B97.9020703@redhat.com>
Message-ID: <4E7B5D20.5060107@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 22.9.2011 18:00, Milan Broz napsal(a):
> 
> On 09/22/2011 11:52 AM, Zdenek Kabelac wrote:
>> Patchset fixed restart of clvmd with -E option.
>>
>> 1st. Adds support for easier restart of clvmd
>>      (i.e.  -Isinglenode is preserved).
>>
>> 2nd. Bug fixes support of -E arg.
> 
> ack these two.
> 
> (maybe cluster lock type is on of the attribute we can store
> in udev db? to read it later :-)
> 
> 
>> 3rd. Allows to build test suite script for checking clvmd restart.
>>      (Any better idea here ?)
> 
> We need something for testsuite but I would like to avoid any online
> reconfiguration of daemon paths, this is tricky and bug there is
> security problem (clvms -S must not start arbitrary program
> - it run with root privileges.)

Note - setting  (LVM_CLVMD_BINARY as was suggest by agk) must be done before
executing the first clvmd.

You can't influence anything by any further  clvmd -S call - since this
environment is not passed to the original restarting daemons.

Thus it should not introduce security risk here - as you are working only with
settings you've had with the first start.

(If someone could manipulate root's environment - he could surely replace disc
content as well)

Zdenek



