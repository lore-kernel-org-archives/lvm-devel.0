From: Marian Csontos <mcsontos@redhat.com>
Date: Thu, 14 Jun 2018 09:46:24 +0200
Subject: v2_02_178 annotated tag has been created
In-Reply-To: <5B21D388020000F900022DFC@prv1-mh.provo.novell.com>
References: <201806131238.w5DCcUL1026320@lists01.pubmisc.prod.ext.phx2.redhat.com>
	<5B21D388020000F900022DFC@prv1-mh.provo.novell.com>
Message-ID: <05d3e93c-0fae-e1f8-c2cd-6e698eb60d02@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 06/14/2018 04:31 AM, Gang He wrote:
> Hello Marian and List,
> 
> Congratulations first.
> As you know, after v2_02_178, LVM in master branch will jump to v3_0_0 with some huge changes.
> But, if we find some bugs in the future on v2_02_178, the fix will be submitted to which branch?
> beside master branch, do we have a v2.02_178.x  (or v2.02_179) to maintain LVM v2 for a few years.

Hi Gang, there is *2018-06-01-stable* branch for 2.02.N development i.e. 
mainly bugfixes.

If needed, there is also *2018-05-17-put-format1-and-pool-back* branch, 
with one patch adding back the LVM1 and GFS pools which applies cleanly 
on top of 2.02.178.

Cheers!

Marian


