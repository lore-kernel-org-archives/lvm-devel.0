From: Bryn M. Reeves <bmr@redhat.com>
Date: Thu, 30 Mar 2017 10:18:38 +0100
Subject: [PATCH] dmsetup: Flush ouptut when using --interval
In-Reply-To: <20170326070615.9880-1-nsoffer@redhat.com>
References: <20170326070615.9880-1-nsoffer@redhat.com>
Message-ID: <20170330091837.GA8333@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Mar 26, 2017 at 10:06:15AM +0300, Nir Soffer wrote:
> A program may like to run "dmstatus report --interval 2" and read the
> report output via a pipe. Flush stdout after outputting each report to
> make this possible.
> ---
>  tools/dmsetup.c | 1 +
>  1 file changed, 1 insertion(+)

Merged, thanks!

Bryn.


