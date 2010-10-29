From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 29 Oct 2010 21:56:48 +0200
Subject: Patch for fsadm bz 64146
In-Reply-To: <4CCB2668.8020809@redhat.com>
References: <4CCB2668.8020809@redhat.com>
Message-ID: <4CCB2700.7000200@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 29.10.2010 21:54, Zdenek Kabelac napsal(a):
> This patch address problem from  BZ 64146.

Correct number is 641461

https://bugzilla.redhat.com/show_bug.cgi?id=641461

> 
> Instead of leaving lvresize to fail when running on the mounted fs (user
> expects online resize to happen and it's currently possible only with -n
> option) - this patch changes 'fsadm check' behavior so it returns success for
> mounted  filesystem. This allows lvresize to processed further and run the
> online resize even without passing -n option.
> 
> Anyone sees this modified behavior of fsadm script as a problem ?
> (change success for mounted fs).
> 
> Zdenek
> 
> 
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


