From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 7 Aug 2007 13:55:05 +0100
Subject: Re: LVM2 ./WHATS_NEW man/lvconvert.8 man/lvcreate. ...
In-Reply-To: <20070801210107.14976.qmail@sourceware.org>
References: <20070801210107.14976.qmail@sourceware.org>
Message-ID: <20070807125505.GP2064@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Aug 01, 2007 at 09:01:07PM -0000, jbrassow at sourceware.org wrote:
> +		log_arg = arg_str_value(cmd, log_ARG, "disk");

Should probably put that hard-coding into defaults.h.

Alasdair
-- 
agk at redhat.com


