From: Bryn M. Reeves <bmr@redhat.com>
Date: Tue, 28 May 2013 12:07:30 +0100
Subject: Bug Report
In-Reply-To: <519FEA6D.6080001@me.com>
References: <519FEA6D.6080001@me.com>
Message-ID: <51A48FF2.7040907@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 05/24/2013 11:32 PM, Rajiv Shah wrote:
> I am reporting a bug on behalf of William Schaub at the Ubuntu Launchpad
> Bug Tracker. The link below directs you to the report and a patch.
> https://bugs.launchpad.net/ubuntu/+source/lvm2/+bug/1173904

The patch attached to the launchpad ticket modifies debian/rules and 
debian/dmeventd.install to enable internal mirrors and add the correct 
dmeventd files.

The debian directory is not included in upstream lvm2 so this needs to 
be changed in the Ubuntu packaging.

There's another hunk changing tools/Makefile.in but it just shuffles 
some LVMLIBS/LIBS command line arguments around - it doesn't look like 
it actually fixes anything.

Regards,
Bryn.


