From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 11 Mar 2010 14:57:04 -0500
Subject: [PATCH] Fix segfault when destroying in-use filters in pvs -a.
In-Reply-To: <1268257407-16371-1-git-send-email-mbroz@redhat.com>
References: <1268257407-16371-1-git-send-email-mbroz@redhat.com>
Message-ID: <4B994B10.9080409@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 03/10/10 16:43, Milan Broz wrote:
> Because pvs -a iterate throught the whole device cache
> we should not refresh filters inside iteration.
> 
> Fix it by introducing simple reference counter and test
> it in refresh_filters() call.
> 
> Fixes https://bugzilla.redhat.com/show_bug.cgi?id=571963

I've tested this patch. By a pvs command with this patch, no segfault
occurred on the same test cases which caused segfault.

Tested-by: Takahiro Yasui <tyasui@redhat.com>

Thanks,
Taka


