Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 15D551DDC8
	for <lvm-devel@lists.linux.dev>; Fri, 20 Oct 2023 21:34:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="ZBj5IVLR"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1697837695;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=UqWHCDY6om6+RgYCuZ4umevTRoeHpT0IwkBTV2OEugE=;
	b=ZBj5IVLR2h1lU6t4ptG8KOzbJTj6SaK7kROWW/A5M0D0zWnhlVd3nCP6UXl9enBoxF/1kr
	AzBjniwcrX53kmMK/Ed+zAoVGNkjm7Qu4We4grXijc02B4g8lTNsOFxdCQa3E0Vj3867RG
	VfIzpeVpajccr7Fd7B4EPfVeN0hbahM=
Received: from mail-oa1-f69.google.com (mail-oa1-f69.google.com
 [209.85.160.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-61-XhfLtpGTM6CyBqyQv03Ybw-1; Fri, 20 Oct 2023 17:34:39 -0400
X-MC-Unique: XhfLtpGTM6CyBqyQv03Ybw-1
Received: by mail-oa1-f69.google.com with SMTP id 586e51a60fabf-1dcf6a4378bso1687936fac.3
        for <lvm-devel@lists.linux.dev>; Fri, 20 Oct 2023 14:34:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1697837678; x=1698442478;
        h=in-reply-to:content-disposition:mime-version:references:message-id
         :subject:to:from:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=UqWHCDY6om6+RgYCuZ4umevTRoeHpT0IwkBTV2OEugE=;
        b=s+X317J9dVHbY0RvvabmOv6N7ZeE3GzfFFLZ0wZPDcXcH7oyzoOsvnR4sTq8TrfpRM
         o1CNbF341pZYce1bcRIhVgpRoz5WnMTHdbiClAupCpVqgQiYACHP2fsAnmZo2vy9GkCb
         5GWgDSwkGZ/+93IhvZW4ryzyeUJnrKBJGdJT/fdwFQTRQMqefnGB20nk6CRXWX0B5wk8
         XXy88H6tYDpWSllbhfcRDzuxcxuOc0cRWzl6o6pHlkVYy2FYMm1/+613Lc7alYL3m8HY
         LjkJ0DSyi0F2NToFEZfJEwPWqTLQCm2ukl5WC4ipnlsOlER1Pbra3y6p+HGDDyHQgH40
         wvug==
X-Gm-Message-State: AOJu0YzbzmKMaWdKFqX8E2+69jk5rZJpvF7HVfAzXimtkI3QkAqznIwl
	owiVDxCTuZXfQR+0bEYBxt2XtepNV+qPyTLjiyeDfRvv/pYa/x8n8rucXPZzT2RlkNtYLjpcM2H
	ydN96Qll7Y4+0gpQp5DkAImlI8I2mzqdmfvRbHB6PQjgnEBeiZkm2XUtWnszUA/aoQ9ztQ0+ziK
	QIxKM=
X-Received: by 2002:a05:6870:1ec4:b0:1e9:89b0:f2b3 with SMTP id pc4-20020a0568701ec400b001e989b0f2b3mr3847707oab.1.1697837678224;
        Fri, 20 Oct 2023 14:34:38 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IFrteNQQGhrSW7MDpV9uRVpB74YktV29WWjPVWpfETWaxk2KedXy0DLUUrtEeOt5lOwo1eFGw==
X-Received: by 2002:a05:6870:1ec4:b0:1e9:89b0:f2b3 with SMTP id pc4-20020a0568701ec400b001e989b0f2b3mr3847696oab.1.1697837677733;
        Fri, 20 Oct 2023 14:34:37 -0700 (PDT)
Received: from localhost (pool-68-160-141-91.bstnma.fios.verizon.net. [68.160.141.91])
        by smtp.gmail.com with ESMTPSA id z6-20020a0cda86000000b0064c9f754794sm987067qvj.86.2023.10.20.14.34.37
        for <lvm-devel@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 20 Oct 2023 14:34:37 -0700 (PDT)
Date: Fri, 20 Oct 2023 17:34:36 -0400
From: Mike Snitzer <snitzer@redhat.com>
To: lvm-devel@lists.linux.dev
Subject: lvm-devel has migrated to lists.linux.dev [was: Re: Welcome to the
 "lvm-devel" mailing list]
Message-ID: <ZTLybIL0gBcfDEe2@redhat.com>
References: <mailman.0.1697833396.3533474.lvm-devel@redhat.com>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <mailman.0.1697833396.3533474.lvm-devel@redhat.com>
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi,

[Sorry for the noise of the previous mailman email, please ignore it.]

As a lvm-devel@redhat.com subscriber, you have been silently subscribed
to the new mailing list: lvm-devel@lists.linux.dev.

Effective immediately, all lvm-devel email should be addressed to:
lvm-devel@lists.linux.dev

If you do send email to lvm-devel@redhat.com you will get this
auto-response:

  Your email to lvm-devel@redhat.com was delivered using
  lvm-devel@lists.linux.dev because:
  As of 2023.10.20: lvm-devel@redhat.com has migrated to
  lvm-devel@lists.linux.dev

  Please update the lvm-devel address to lvm-devel@lists.linux.dev

  If you were a lvm-devel@redhat.com subscriber you have been silently
  subscribed to lvm-devel@lists.linux.dev

  Please be sure to update any lvm-devel mail filter you may have to look
  for this in mail headers:
  List-Id: <lvm-devel.lists.linux.dev>

  NOTE: If you, or a friend, were a lvm-devel@redhat.com subscriber
  with disabled mail delivery: then you must subscribe to
  lvm-devel@lists.linux.dev.  To do so please send email to:
  lvm-devel+subscribe@lists.linux.dev

  To unsubscribe from lvm-devel@lists.linux.dev please send email to:
  lvm-devel+unsubscribe@lists.linux.dev

The lvm-devel list archive will soon be migrating here:
https://lore.kernel.org/lvm-devel/

Please let me know if you have any questions or concerns.

Thanks,
Mike

