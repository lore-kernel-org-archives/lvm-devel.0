From: Bryn M. Reeves <bmr@redhat.com>
Date: Fri, 14 Aug 2015 11:35:32 +0100
Subject: [PATCH] libdm: do not in include internal bits/time.h header
In-Reply-To: <1439450188-3686-1-git-send-email-ncopa@alpinelinux.org>
References: <1439450188-3686-1-git-send-email-ncopa@alpinelinux.org>
Message-ID: <20150814103531.GB6851@bmr.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Aug 13, 2015 at 09:16:28AM +0200, Natanael Copa wrote:
> Do not include bits/time.h as it is an internal libc header file.
> 
> A comment at the top of the glibc specific bits/time.h says:
> "Never include this file directly; use <time.h> instead."
> 
> This fixes the following build error with musl libc:
> libdm-timestamp.c:37:23: fatal error: bits/time.h: No such file or directory

Applied - thanks!

Regards,
Bryn.


