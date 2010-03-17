From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 17 Mar 2010 12:50:48 -0400
Subject: [PATCH 2/3] Add find_vgname_from_pvname() function using lvmcache functions.
In-Reply-To: <1268841108-19327-3-git-send-email-dwysocha@redhat.com>
References: <1268841108-19327-1-git-send-email-dwysocha@redhat.com>
	<1268841108-19327-2-git-send-email-dwysocha@redhat.com>
	<1268841108-19327-3-git-send-email-dwysocha@redhat.com>
Message-ID: <1268844648.2476.1.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 2010-03-17 at 11:51 -0400, Dave Wysochanski wrote:
> +char *find_vgname_from_pvname(struct cmd_context *cmd, const char
> *pvname)
> +{
> +       char *vgname;
> +       struct lvmcache_info *info;
> +
> +       /*
> +        * Initially, all we have is a pv name - we don't know the VG
> name.
> +        * Try to look the name up in lvmcache.
> +        */
> +       lvmcache_label_scan(cmd, 0);
> +       vgname = lvmcache_vgname_from_pvname(cmd, pvname);
> +

Actually the lvmcache_label_scan() should not be necessary here.

We read the label for the device later and the expensive scans if
necessary (orphan and no mdas).


