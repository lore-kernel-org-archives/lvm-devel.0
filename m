From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 18 Dec 2008 00:18:29 +0000
Subject: [RFC][PATCH] Create global is_static() to eliminate from the library init function.
In-Reply-To: <1229556431-14791-1-git-send-email-dwysocha@redhat.com>
References: <1229556431-14791-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20081218001829.GH25976@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 17, 2008 at 06:27:11PM -0500, Dave Wysochanski wrote:
> Very simple / crude method of removing 'is_static' from initialization.
 
Ack.

> Why should we require an application tell us whether it is linked
> statically or dynamically to libLVM?  If the application is linked
> statically, but libraries exist and dlopen() calls succeed, why
> do we care if it's statically linked?

is_static was introduced for the initrd and caused some other
functionality not required there to be disabled too.

Then we changed Fedora to support shared libraries in the initrd.
That meant providing an alternative way to deal with the features
that need to be disabled in the initrd instead of overloading
is_static.

Much of that logic is about suppressing unnecessary messages during
booting and coping with systems that didn't customise lvm.conf for
the initrd.

Alasdair
-- 
agk at redhat.com


