Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 71EED37BE64
	for <lvm-devel@lists.linux.dev>; Thu, 23 Apr 2026 11:47:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776944876; cv=none; b=V/ght7L9GRefXsKP724+LR1yxR3DSrSSnCEOCcGypwWNEvYv1LMcAaGAzethZ9Jzr6IJbirMcmzuizVIyCLLKM1sQUbG1DjWHugmP3h+6vE2okIfQLf+FniHmZoUXbghmp2qfjYPW19G7UmpzRwzIw5LBeTl3RjlQLxOntFIFG8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776944876; c=relaxed/simple;
	bh=3TVK7Z+xXFmLQzW+MkiG4J0B4+DUK7A5D6OambWgaYc=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=sUC1Q/ihWNjbtDFd/xcCPBcEKN0cgQuWmBWgMJENiC3DkJlCtpYEdOZOgzi5ZzMFzMLPUa5ULSX0gZVDXJ3cA1zs8Iu7AGb0vZJyc0g1oD/1zuTCtp3NP39s+wDWUlvPH1ge7DvbZa48MVeQMg80EBwqNpqngmMQIaCvpwtwXIA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=buMb5wWy; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="buMb5wWy"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1776944871;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=odQYoE1BR41cvVPHN6tSLjUU96O51B2DOlzaxL/g1Kg=;
	b=buMb5wWyBLgzVydvzzd/xmw7ZMmOL7QA2ewQO/FN39CDnEk+5xDTGNf6RzKSPH8ySFLb6R
	BCcLKmxa/MQu48bRu8K/xXrNUzP/Mu8RzkagxqdM2aUcFb+4b7Lw9WhJDIzsnpoVuHcZWl
	xoiBZOT+1xIhUkSf5ZK20qJKzvR7rjY=
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com
 [209.85.221.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-568-G8-_HooQP_qgRgnN8qmgUA-1; Thu, 23 Apr 2026 07:47:45 -0400
X-MC-Unique: G8-_HooQP_qgRgnN8qmgUA-1
X-Mimecast-MFC-AGG-ID: G8-_HooQP_qgRgnN8qmgUA_1776944863
Received: by mail-wr1-f70.google.com with SMTP id ffacd0b85a97d-43cff5ef652so4193036f8f.2
        for <lvm-devel@lists.linux.dev>; Thu, 23 Apr 2026 04:47:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1776944863; x=1777549663;
        h=content-transfer-encoding:in-reply-to:organization:from
         :content-language:references:to:subject:user-agent:mime-version:date
         :message-id:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=odQYoE1BR41cvVPHN6tSLjUU96O51B2DOlzaxL/g1Kg=;
        b=khphCYmmJpqYPb7rD1UY55SoNWcY03uk1y26lw6ucOTbLsV4yWDMUs8LjeYpJhpwAB
         QcSZ1TL91UyDAZ4xzp0SInU+X8XCe7EDD/WDsz/ikR8nWFiE0f1bg9lM4lWHpu8347mR
         eVia2o1UmGHb/8iRh/zjoETjDsLozPNaBhZP5CeDvEM09kGAxclKk+vq2Z2+1I8ku4QL
         Thm3Zi+2aY+SS1PjrW8X4R7c6b5uaXLJrqnWB5Nk65W9qUM74ermuJzOF4z7Ph44MkKQ
         59EuaUjHlqsYx853LhLywmk55+KXviXBDTcv+PpQYCiiDgJxKj4tU9vnZiOrx0j1nrT6
         hgaQ==
X-Forwarded-Encrypted: i=1; AFNElJ8qeAJ3WFSu6qrvtwb8GnmWK/t1hGs3yoNjHaRZK6Rdx6VOd6eVAgp6MTEmRCu9KXxXomulBy8DPzg=@lists.linux.dev
X-Gm-Message-State: AOJu0YzDK6uT1Wzn5GHWbjrNV3Sp/vaPS9NEffXIMOC449TK04xEw5YD
	MdSOVHKC0K8XQ9tThbRurqaLp0CG1ldEV9zYdkNw948sglFxBUW+xgrJlCOfQmNWSY5eC2husyO
	81F8ZdQi/3A9Q4L+6gY/Jof3mqNQN15DhZKGOgLGBI4zPGrnCrf54rIPYSzLTqw==
X-Gm-Gg: AeBDiesJ6K0IRNPp6/Qeaupup8CcHQ8LpaQkEF0ZrbMZqhsq4QYBwP1BMRFy6bBKyH5
	3LITN+BGj/yl84sKDnOn/tu62bk4C+mPxUvgNCMwDZl+hy8N0dOWjVBdZjzsJwd2uBX2MWonVxH
	iuwVCCftMu2zXczbn5VJEBfN1nNNeCAhwcYc+7NemZf139CS6n0NZMxi/JEa+piVl3yruIcPOtG
	o5V6hAskBLD8MEmnwu5v9O2jZ3lbZ8WXjktD8b3HFHX2rx0q0msKZ6MMM36sM116WD9ujEjLVjh
	4zt4JnV7trOiNJcPKxj4c+RpoNf3wwB+U/vjXJRsPEXm5o2f5llnuBbubuusqrXTNkZyODy4+TR
	Vu06g8Y8ayl2y2IZtFRNTYGrtDT+GbBVLKic8No1cuL1s+nTLfWZVcHbHT+YBlMUWpag=
X-Received: by 2002:a05:6000:2212:b0:43c:f583:126a with SMTP id ffacd0b85a97d-43fe3dcaee5mr41905601f8f.14.1776944862598;
        Thu, 23 Apr 2026 04:47:42 -0700 (PDT)
X-Received: by 2002:a05:6000:2212:b0:43c:f583:126a with SMTP id ffacd0b85a97d-43fe3dcaee5mr41905554f8f.14.1776944862137;
        Thu, 23 Apr 2026 04:47:42 -0700 (PDT)
Received: from [192.168.0.99] ([212.20.115.16])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-43fe4e3a166sm51437412f8f.19.2026.04.23.04.47.41
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Thu, 23 Apr 2026 04:47:41 -0700 (PDT)
Message-ID: <a3771765-8ada-459f-a1da-a67723469d98@redhat.com>
Date: Thu, 23 Apr 2026 13:47:41 +0200
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH] man: fix typo in lvmcache.7
To: lichun <lichunplus@gmail.com>, lvm-devel@lists.linux.dev
References: <20260423023250.11324-1-lichunplus@gmail.com>
From: Zdenek Kabelac <zkabelac@redhat.com>
Organization: RedHat
In-Reply-To: <20260423023250.11324-1-lichunplus@gmail.com>
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: MKtL3NJkDwnumEQ-wUYYbcmDue0JbU4Bbfweru7zvvc_1776944863
X-Mimecast-Originator: redhat.com
Content-Language: en-US, cs
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

Dne 23. 04. 26 v 4:32 lichun napsal(a):
> Correct /dev/slow_hhd to /dev/slow_hdd"
> 

Thanks, will be merged.

Zdenek

