Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 97D4B2D8762
	for <lvm-devel@lists.linux.dev>; Sun, 27 Sep 2026 07:02:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790492523; cv=none; b=ZuvMPUQ2zVvn05RwSc4rcgL1mBtK5g9zMBtdTODr0a4jeH36GPFVEFfZpmmgXMEQetsttSMsp5W3yoJqrRvyARQ6u/Z2GCofSuoZFxw6SvroGZtoedmrNUdWDxjXVRdnhWDwiN4FmFyYeUQIs2aC/hmgNVkTpOdcqeRaFNpoKqM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790492523; c=relaxed/simple;
	bh=8+qzCFIqivWFQJyxUEHksoseC4pF4KSjEpvanwRohko=;
	h=Message-ID:Date:MIME-Version:From:To:Subject:References:
	 In-Reply-To:Content-Type; b=J5V5H6m71PwmJkh4q5BEGm/NjyokXXkDczF94zZ4LCBXTzLghVC5f/2nFwlSvQDtdKFID017D1dpIiEAoNQs7atrfnGgYUhAcMeeFnmmIO/ch+YclLt8HWvuaH/EvOss9FEYi1i7wkdvEysjZqyepzKp0skktKKvwwnRpIzQhU8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=S+Yr1XdR; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="S+Yr1XdR"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1790492520;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=cyhknH8q/rlEzC7l26WfMmu0X0rTbK+AaNQiPL1AXw8=;
	b=S+Yr1XdRKjuI8KcGVUKk7cWYL8ANjeusx1+BagaZQGoXkPb3kraRD7QTnCchly3JQuO1Md
	9rDKQemuAefj8nbn/OJBdOt+Xl2I4PBmDWh8CNYvLPbAKK2+9JE/ZYBruY3NG58bNJ/zvu
	LOCHcQC0bpOxYh/jUIqOD90hstpOuD4=
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com
 [209.85.221.72]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-490-R_hxEToPOXuss3Cm_fHf7w-1; Sun, 27 Sep 2026 03:01:56 -0400
X-MC-Unique: R_hxEToPOXuss3Cm_fHf7w-1
X-Mimecast-MFC-AGG-ID: R_hxEToPOXuss3Cm_fHf7w_1790492515
Received: by mail-wr1-f72.google.com with SMTP id ffacd0b85a97d-48879e03053so1131042f8f.0
        for <lvm-devel@lists.linux.dev>; Sun, 27 Sep 2026 00:01:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790492515; x=1791097315;
        h=content-transfer-encoding:content-type:in-reply-to:references
         :subject:to:from:user-agent:mime-version:date:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=cyhknH8q/rlEzC7l26WfMmu0X0rTbK+AaNQiPL1AXw8=;
        b=IyKhaqFhaAe1P5ZJqRGQi1fh0uAh82of586aBVByheIrun+oY+DYdbTbegCpvmzHd3
         qeZ2DZW6O/ZjYAlEEfAVqRLT9WjCCpaL65zlPMFQXD2/TWUEaCvNOtZx13oaX8Hz3fZu
         VcD7IcSc6rRlVnlHYPEDBco6YO3K7Y8ZnwJ1CQN3ykUIhDtmS7eQS+s5jSlF2nTZjs6t
         +wsiGVIdyeAQoukBIgzWI4S6lko/Gv+B7zyYl291hksUKJpFe1xsKuXlb8m+BoCHHwtu
         X0mEtloKXsm2UL7lWEdfT7QUPd4dFwaX22QEgeHfc0sgWMXCQBm/c9FHv203ZjEjIagE
         1QbQ==
X-Forwarded-Encrypted: i=1; AKwUvBytm13pFO2Dbydvv5VUAy7JDtIJQ6csbHJCbtsUuj8EFYmUA8O/OzxWPo7WcmaqknHZi+GM95Xlz7o=@lists.linux.dev
X-Gm-Message-State: AFuF++m4dVlCsEED5QPzM7c4kYITG+cIvPu+4QH4OU42YMn5tMHCPa/6
	CTZHLI+qmqInGmxL/qCBmG7v08DH8PYt7vYCq5AHUz2rQwNMzs6cBt4lo8C3NctKYbCeaJBcEwK
	Gxt/6dXvyufpBtqNUY/Ch786lIpZ/j7yDURRR6PX4PE3ETtO+VFtxqxa4gJfGjqc7XZb0Sg==
X-Gm-Gg: AYBFou3OogWrrdqmWDZ9cp+337F+mJ6LlNRRXXBwCVgsuh1j5yRfzxCuURCFIStb7Rx
	rVUXbbeZECa6w8eR/9FM/hMTd/gD4DIYg0rBtaqvfdb1bYzWhmdk91KUxzKzg8yiEJLuJElc0+J
	9gtX6xV5mgB130rg0cVt0JnpU+iAz85H6CkE2ZSeAVZAssVju3NmyIMix36MFaUmokC6Dwj2p0G
	93hTKdhScGufDkQdol+Mzxy69N9SQ7qMlUsBv1rZxMkD69JU8uryW9Z9ZlhEFOEjGwMrpBe7fp3
	R3JJJlth7MQpburaWfdKrF5phTTBAa8xPOhBkTAhc7d9VxzIHVzqS9VRraUW9j7LFzv0RVB1RwW
	Lhg==
X-Received: by 2002:a05:600c:4e53:b0:49c:e37e:4389 with SMTP id 5b1f17b1804b1-49fe66c8288mr175000005e9.4.1790492515017;
        Sun, 27 Sep 2026 00:01:55 -0700 (PDT)
X-Received: by 2002:a05:600c:4e53:b0:49c:e37e:4389 with SMTP id 5b1f17b1804b1-49fe66c8288mr174999485e9.4.1790492514256;
        Sun, 27 Sep 2026 00:01:54 -0700 (PDT)
Received: from [192.168.0.99] ([212.20.115.16])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4a0018dd0ffsm37840185e9.2.2026.09.27.00.01.53
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sun, 27 Sep 2026 00:01:53 -0700 (PDT)
Message-ID: <d260c81c-a036-4d8b-95bf-313971ef0fb7@redhat.com>
Date: Sun, 27 Sep 2026 09:01:53 +0200
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
From: zkabelac@redhat.com
To: Paul van Genderen - Tjie A Loi <paul.vangenderen@freedom.nl>,
 lvm-devel@lists.linux.dev
Subject: Re: Missing path component in dmsetup(8) manual page
References: <d979be8a93464508f3944a2a3165d723@freedom.nl>
In-Reply-To: <d979be8a93464508f3944a2a3165d723@freedom.nl>
X-Mimecast-Spam-Score: 0
X-Mimecast-MFC-PROC-ID: dWWpEHYqU5VnYalRBBB8KLzFr6GY5V5zE77rMbdz_Ow_1790492515
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 26.09.26 14:12, Paul van Genderen - Tjie A Loi <paul.vangenderen@freedom.nl> wrote:
> Hello,
> 
> I noticed a missing path component in the manual page for dmsetup.
> The path mentioned was: Documentation/device-mapper but it should
> be: Documentation/admin-guide/device-mapper.
> Attached patch fixes the problem and I've tried to ensure line
> breaks happen in the right places.
> 
> Regards,
> Paul
> 

Hi

Thanks, upstreamed as:
https://gitlab.com/lvmteam/lvm2/-/merge_requests/194/diffs?commit_id=e25b51b5ea248b3269d46ed7c3794c1930df7458

Zdenek

