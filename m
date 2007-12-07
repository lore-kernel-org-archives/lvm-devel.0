From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 07 Dec 2007 10:48:47 -0500
Subject: [PATCH pvmove 0/6] Refactoring pvmove with generic APIs
In-Reply-To: <20071207114954.GA6313@redhat.com>
References: <475825EF.6000803@ce.jp.nec.com> <20071207114954.GA6313@redhat.com>
Message-ID: <47596B5F.3010005@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Heinz,

Thanks for the comment.

Heinz Mauelshagen wrote:
> it would be better to make this more generic.
> 
> Ie. convert_segments(struct lvm_conversion_handler *handler, ...)
> rather than having a per target conversion function.

Yes, generic interface is nice.
But as for conversion, I think starting from per-target
conversion functions is better.


We may have a generic library interface like this:

  int lv_convert(struct logical_volume *lv,
                   struct segment_type *segtype,
                   struct conversion_param *conv)

The conversion parameters are very specific to segment types.
So callers have to set up the conversion_param based on the segtype.

Parameter are perhaps passed as an array of name-value pairs.
I.e.
  struct conversion_param {
     int n_params;
     struct {
       const char *name;
       const char *value;
     } *params;
  }

 conv = { 4,
           { { "mirrors", "3" }, { "region_size", "64" },
             { "log_count", "0" }, { "type", "segment-by-segment" } }
         }

And the segment type handlers interpret it.
I think it's good for external applications using liblvm2
but too much for LVM2 internal use.

What do you think?

Anyway, IMO, it's easy to add a generic wrapper once we make up
underlying conversion functions for each segment types.
So I think we should focus first on building up working conversion
functions.

This pvmove patchset provides segment-by-segment conversion for
mirror.
Next step would be whole-lv conversion for mirror.
Then we can add a single wrapper for to-mirror conversion.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America


