From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 30 Jan 2015 10:54:29 +0100
Subject: "lv_attr" disappeared from lvm_lv_get_property?
In-Reply-To: <54CB5213.7030108@redhat.com>
References: <87r3udicy7.fsf@red.mvo.lan>, <87oapgiu3z.fsf@red.mvo.lan>,
	<54CB4B79.8000005@redhat.com> <87mw50ipfv.fsf@red.mvo.lan>
	<54CB5213.7030108@redhat.com>
Message-ID: <54CB54D5.3080402@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/30/2015 10:42 AM, Peter Rajnoha wrote:
> On 01/30/2015 10:32 AM, Marius Vollmer wrote:
>> Do you know of any users besides storaged?
>>
> 
> Anaconda was one of the candidates to use liblvm, but afaik, they're
> still forking LVM commands.
> 
> The other one I know of is the udisks, but it removed support for LVM
> some time ago and udisks2 and later does not handle LVM anymore.
> 
> And then your use case :)

+2 more - collectd and glusterfs-server, at least on Fedora:

[1] f21/~ # repoquery --whatrequires lvm2-libs
collectd-lvm-0:5.4.1-8.fc21.x86_64
glusterfs-server-0:3.5.3-1.fc21.x86_64
storaged-0:0.3.1-1.fc21.x86_64

-- 
Peter


