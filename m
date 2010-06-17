From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 17 Jun 2010 17:10:32 -0500
Subject: Patch for adding --resize to manpage
In-Reply-To: <4C0E4304.9030601@redhat.com>
References: <4C0E4304.9030601@redhat.com>
Message-ID: <98BA4E4E-36F1-4A2F-9F1B-326C85F3BFE0@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Under lvextend/'--force', s/without any question/without any questions/.

Under lvextend/'--resizefs', The sentence about 'fsadm' seems to imply  
that it is necessary in addition to the argument.  Is this the case?   
If not, perhaps we could say something like, "fsadm can be used to  
resize a filesystem separately if this option is not used."

Under lvreduce, is there no '--force' option?  If not, we should  
probably remove a reference to in in '--nofsck'.

Under lvreduce/'--resize', same comment concerning fsadm.

Under lvresize/'--force', s/question/questions/

Under lvresize/'--resize', same as above

Otherwise, seems fine.
  brassow

On Jun 8, 2010, at 8:17 AM, Zdenek Kabelac wrote:

> Here is proposal for adding documentation about --resizefs, -- 
> nofsck,--force option for lvextend, lvresize, lvreduce.
>
> It should resolve: https://bugzilla.redhat.com/show_bug.cgi?id=592428
>
> Zdenek
>
> <Man-page-update-for-lvresize-resizefs.patch>--
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


