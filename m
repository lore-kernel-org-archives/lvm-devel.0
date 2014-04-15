From: Bryn M. Reeves <bmr@redhat.com>
Date: Tue, 15 Apr 2014 14:48:38 +0100
Subject: master - lvmdump: list also inactive units for lvmdump -s
In-Reply-To: <20140415134333.57570602BE@fedorahosted.org>
References: <20140415134333.57570602BE@fedorahosted.org>
Message-ID: <20140415134837.GB25167@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Apr 15, 2014 at 01:43:33PM +0000, Peter Rajnoha wrote:
> lvmdump: list also inactive units for lvmdump -s
> 
> ---
>  scripts/lvmdump.sh |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

For Red Hat (inc. Fedora, CentOS and RHEL) and recent Debian / Ubuntu
distributions you could also request an sosreport. The tool has support
for collecting lvmdump data, for e.g.:

# sosreport -o lvm2 -o systemd -klvm2.lvmdump

Would collect a similar set of data. The lvmdump option defaults to off
currently but I've considered switching this over to always collect
them.

Regards,
Bryn.


