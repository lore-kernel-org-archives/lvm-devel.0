From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 19 Oct 2012 15:39:52 +0200
Subject: clvmd always sets debug level to DEBUG_SYSLOG
In-Reply-To: <20121019143301.4cc7e9ac@coolcat.suse.cz>
References: <20121019143301.4cc7e9ac@coolcat.suse.cz>
Message-ID: <50815828.90309@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 19.10.2012 14:33, Robert Milasan napsal(a):
> Hello,
> just realized now that in clvmd.c debugging level is set wrong due to
> using the wrong variable in clvmd_set_debug.
>
> If a user run clvmd -d0, usually this means no debugging or DEBUG_OFF,
> but 0 argument is saved in debug_arg and debugging level is set using
> debug_opt in clvmd_set_debug:
>
> # cat clvmd.c |grep clvmd_set_debug
>          clvmd_set_debug(debug_opt);
>
> and it suppose to be: clvmd_set_debug(debug_arg)
>
> Here is the patch:
>

Thanks for noticing, the patch (in a bit updated version) pushed upstream.
(https://www.redhat.com/archives/lvm-devel/2012-October/msg00166.html)

Zdenek


