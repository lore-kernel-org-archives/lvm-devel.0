From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Wed, 16 Feb 2022 22:22:32 +0530
Subject: Reg auto metadata drive growth
Message-ID: <CAFe+wq32gErNeFgy0YAm3DQ-0dcTbYDtKGfv=pY5VXwU-Yi_nA@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Team!
A very good day to you.

I am currently using a dm thin pool/volume in my setup.
I initially created a metadata device that is about 2G with a chunk size
64K.

I refer to the link below for some follow up queries.
https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/8/html/configuring_and_managing_logical_volumes/assembly_thinly-provisioned-logical-volumes_configuring-and-managing-logical-volumes

<snip begin>

By default, lvm2 starts with a 64KiB chunk size and increases its value
when the resulting size of the thin pool metadata device grows above
128MiB, this keeps the metadata size compact. However, this may result in
some big chunk size values, which are less space efficient for snapshot
usage. In such cases, a smaller chunk size and a bigger metadata size is a
better option.

If the volume data size is in the range of TiB, use ~15.8GiB as the
metadata size, which is the maximum supported size, and set the chunk size
as per your requirement. But, note that it is not possible to increase the
metadata size if you need to extend the volume?s data size and have a small
chunk size.
<snip end>

In my environment I pass chunk size during thin pool creation.
I compute the chunk size starting from 64K and doubling based on the
backing storage availability and the number of thin volumes and sizes to
support.
The second para above needs some clarification, especially on the limits.

a) I read that for each TiB of supported thin volume, ~15.8GiB of metadata
volume gets used. I believe this condition is computed based on the default
chunk size at 64K. So if the chunk size doubles, then I would assume that
only ~8GiB for each TiB.

b) What is the max supported thin volume size?
c) What is the max supported metadata volume size?

Also, under some scenarios over a period of time I observe that the thin
metadata volume gets full. Under those condition:

1/ Is it possible to manually resize the metadata volume alone?
2/ Is it possible to automatically resize the metadata volume as it reaches
a critical limit?

Can I please have some clarification on the above?

Thanks
LN
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20220216/42f13de1/attachment.htm>
