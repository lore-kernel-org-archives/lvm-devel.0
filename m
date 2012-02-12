From: Alasdair G Kergon <agk@redhat.com>
Date: Sun, 12 Feb 2012 20:11:45 +0000
Subject: LVM2 ./WHATS_NEW lib/activate/fs.c
In-Reply-To: <20120208104343.16759.qmail@sourceware.org>
References: <20120208104343.16759.qmail@sourceware.org>
Message-ID: <20120212201145.GA7066@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Feb 08, 2012 at 10:43:43AM -0000, zkabelac at sourceware.org wrote:
> +	if ((r = lstat(lv_path, &buf)) && errno == ENOENT)

> +	if (r || !S_ISLNK(buf.st_mode)) {
>  		log_error("%s not symbolic link - not removing", lv_path);

So if you get, say ENOMEM, you'll tell the user "not symbolic link"?
Sigh.

Alasdair


