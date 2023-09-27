From: David Teigland <teigland@redhat.com>
Date: Wed, 27 Sep 2023 14:22:13 -0500
Subject: dm integrity with lvm
In-Reply-To: <CAFe+wq3UXfk7aNSkD6c691zPCpo1unYv2NYJYhhwJx7PSgwzqg@mail.gmail.com>
References: <CAFe+wq3UXfk7aNSkD6c691zPCpo1unYv2NYJYhhwJx7PSgwzqg@mail.gmail.com>
Message-ID: <20230927192213.GA17595@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Sep 26, 2023 at 05:01:19PM +0530, Lakshmi Narasimhan Sundararajan wrote:
> Hi Team,
> Good day to all.
> 
> I am checking with the team here to know whether dm-integrity device
> support exists under lvm. I so far have not been able to find any
> references.
> If so, may I know from which version this support got integrated?

It can be used in combination with raid, see DATA INTEGRITY in
https://man7.org/linux/man-pages/man7/lvmraid.7.html
The code appeared in Nov 2019, so somewhere around 2.03.07.

Dave
