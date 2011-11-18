From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 18 Nov 2011 20:53:12 +0000
Subject: [PATCH] Fix RHBZ 754198 (multiple dmeventd snapshot extensions)
In-Reply-To: <4EC6C4AD.9080702@redhat.com>
References: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
	<20111116012039.GB3294@agk-dp.fab.redhat.com>
	<87ehx8xv43.fsf@aldalome.int.mornfall.net.>
	<20111116105953.GD3294@agk-dp.fab.redhat.com>
	<20111116130734.GE3294@agk-dp.fab.redhat.com>
	<87y5vdwydx.fsf@aldalome.int.mornfall.net.>
	<4EC6927B.4000402@redhat.com>
	<87obw9w6vv.fsf@aldalome.int.mornfall.net.>
	<4EC6C4AD.9080702@redhat.com>
Message-ID: <20111118205312.GZ3294@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Nov 18, 2011 at 09:48:45PM +0100, Zdenek Kabelac wrote:
> while  {
>   read percentage
>   if converted && current_percent < last_time_percent

Do that better, not by comparing the percentage, but by comparing the absolute
size (which is also present on the status line).

Alasdair


