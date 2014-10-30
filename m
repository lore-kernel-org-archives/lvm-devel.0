From: Rommer <rommer@active.by>
Date: Thu, 30 Oct 2014 18:57:40 +0300
Subject: [PATCH] Try to convert existing lock on volume reactivation for clustered volume groups.
In-Reply-To: <52B14E83.8040303@redhat.com>
References: <52A14E1A.3030509@activecloud.com>
	<52A18F2B.5070607@redhat.com>	<52A1DB94.1020001@activecloud.com>
	<52A1DFDE.8050706@redhat.com>	<52A29120.2000203@activecloud.com>
	<52B110EF.6070304@activecloud.com> <52B14E83.8040303@redhat.com>
Message-ID: <54525FF4.3000602@active.by>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello,

Patch for the latest lvm2 version.

On 12/18/13 10:28, Zdenek Kabelac wrote:
> Dne 18.12.2013 04:05, Raman Shishniou napsal(a):
>> Hello,
>>
>> Is something wrong with this patch?
>
> I believe the patch is fine. I just need to extend the patch for other
> supported clvmd modes and enhance singlenode to be able to test it works
> and I'm currently busy with fixing other discovered bugs.
>
> Zdenek
>

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-2_02_111-convertlock.patch
Type: text/x-patch
Size: 4986 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20141030/9a7fd53c/attachment.bin>
