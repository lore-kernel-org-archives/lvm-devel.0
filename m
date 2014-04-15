From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 15 Apr 2014 15:59:06 +0200
Subject: master - lvmdump: list also inactive units for lvmdump -s
In-Reply-To: <20140415134837.GB25167@localhost.localdomain>
References: <20140415134333.57570602BE@fedorahosted.org>
	<20140415134837.GB25167@localhost.localdomain>
Message-ID: <534D3B2A.50607@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/15/2014 03:48 PM, Bryn M. Reeves wrote:
> On Tue, Apr 15, 2014 at 01:43:33PM +0000, Peter Rajnoha wrote:
>> lvmdump: list also inactive units for lvmdump -s
>>
>> ---
>>  scripts/lvmdump.sh |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> For Red Hat (inc. Fedora, CentOS and RHEL) and recent Debian / Ubuntu
> distributions you could also request an sosreport. The tool has support
> for collecting lvmdump data, for e.g.:
> 
> # sosreport -o lvm2 -o systemd -klvm2.lvmdump
> 
> Would collect a similar set of data. The lvmdump option defaults to off
> currently but I've considered switching this over to always collect
> them.

Well, yes, if sosreport supports that then that's fine.

The "-s" option for lvmdump is optional anyway. From my perspective,
the most valuable info I can get for debugging is the status of
"lvm2-pvscan@<major>:<minor>.service" which contains valuable logs...

-- 
Peter


