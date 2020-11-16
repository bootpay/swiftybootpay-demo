//
//  ViewController.swift
//  demo
//
//  Created by Taesup Yoon on 2020/11/16.
//

import UIKit
import SwiftyBootpay

class ViewController: UIViewController {
    let application_id = "5b8f6a4d396fa665fdc2b5e9"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setUI()
    }
    
    func setUI() {
        self.view.backgroundColor = .white
        self.title = "부트페이 데모"
        let titles = ["일반 결제 테스트", "생체인증결제 테스트"]
        let selectors = [#selector(nativeClick), #selector(bioPayClick)] 
      
        let array = 0...(titles.count-1)
        let unitHeight = self.view.frame.height / CGFloat(array.count)
      
        for i in array {
            let btn = UIButton(type: .roundedRect)
            btn.frame = CGRect(x: 0, y: unitHeight * CGFloat(i), width: self.view.frame.width, height: unitHeight)
            btn.setTitle(titles[i], for: .normal)
            btn.addTarget(self, action: selectors[i], for: .touchUpInside)
            self.view.addSubview(btn)
        }
    }
}

extension ViewController {
    @objc func nativeClick() {
        // 통계정보를 위해 사용되는 정보
        // 주문 정보에 담길 상품정보로 배열 형태로 add가 가능함
        let item1 = BootpayItem().params {
            $0.item_name = "미\"키's 마우스" // 주문정보에 담길 상품명
            $0.qty = 1 // 해당 상품의 주문 수량
            $0.unique = "ITEM_CODE_MOUSE" // 해당 상품의 고유 키
            $0.price = 1000 // 상품의 가격
        }
        let item2 = BootpayItem().params {
            $0.item_name = "키보드" // 주문정보에 담길 상품명
            $0.qty = 1 // 해당 상품의 주문 수량
            $0.unique = "ITEM_CODE_KEYBOARD" // 해당 상품의 고유 키
            $0.price = 10000 // 상품의 가격
            $0.cat1 = "패션"
            $0.cat2 = "여\"성'상의"
            $0.cat3 = "블라우스"
        }
        
        // 커스텀 변수로, 서버에서 해당 값을 그대로 리턴 받음
        let customParams: [String: String] = [
            "callbackParam1": "value12",
            "callbackParam2": "value34",
            "callbackParam3": "value56",
            "callbackParam4": "value78",
            ]
        
        // 구매자 정보
        let bootUser = BootpayUser()
         bootUser.params {
//            $0.username = "사용자 이름"
            $0.email = "user1234@gmail.com"
            $0.area = "서울" // 사용자 주소
            $0.addr = "서울시 동작구 상도로";
            $0.phone = "010-1234-4567"
         }
      
         let payload = BootpayPayload()
         payload.params {
            $0.price = 1000 // 결제할 금액, 정기결제시 0 혹은 주석
            $0.name = "테스트's 마스카라" // 결제할 상품명
            $0.order_id = "1234_1234_124" // 결제 고유번호
            $0.params = customParams // 커스텀 변수
            $0.application_id = application_id
            
            
            
            $0.pg = BootpayPG.KCP // 결제할 PG사

            $0.account_expire_at = "2020-11-28" // 가상계좌 입금기간 제한 ( yyyy-mm-dd 포멧으로 입력해주세요. 가상계좌만 적용됩니다. 오늘 날짜보다 더 뒤(미래)여야 합니다 )
//                        $0.method = "card" // 결제수단
            $0.show_agree_window = false
//            $0.methods = [Method.BANK, Method.CARD, Method.PHONE, Method.VBANK]
            $0.method = Method.CARD
            $0.ux = UX.PG_DIALOG
         }
      
         let extra = BootpayExtra()
//         extra.popup = 0 //다날 정기결제의 경우 0
//         extra.quick_popup = 0 //다날 정기결제의 경우 0
      
//         extra.offer_period = "1년치"
         
         extra.quotas = [0, 1, 2, 3] // 5만원 이상일 경우 할부 허용범위 설정 가능, (예제는 일시불, 2개월 할부, 3개월 할부 허용)
//         extra.app_scheme = "test://"; // 페이레터와 같은 특정 PG사의 경우 :// 값을 붙여야 할 수도 있습니다.
 
      
         var items = [BootpayItem]()
         items.append(item1)
         items.append(item2)
      
      
        Bootpay.request(self, sendable: self, payload: payload, user: bootUser, items: items, extra: extra, addView: true)
    }
    
    @objc func bioPayClick() {
        readyBootpayBio()
    }
}


//MARK: Bootpay Callback Protocol
extension ViewController: BootpayRequestProtocol {
    // 에러가 났을때 호출되는 부분
    func onError(data: [String: Any]) {
        print("------------ error \(data)")
    }
    
    // 가상계좌 입금 계좌번호가 발급되면 호출되는 함수입니다.
    func onReady(data: [String: Any]) {
      print("------------ ready \(data)")
    }
    
    // 결제가 진행되기 바로 직전 호출되는 함수로, 주로 재고처리 등의 로직이 수행
    func onConfirm(data: [String: Any]) {
        print("------------ confirm \(data)")
        
        let iWantPay = true
        if iWantPay == true {  // 재고가 있을 경우.
            Bootpay.transactionConfirm(data: data) // 결제 승인
        } else { // 재고가 없어 중간에 결제창을 닫고 싶을 경우
            Bootpay.dismiss()
        }
    }
    
    // 결제 취소시 호출
    func onCancel(data: [String: Any]) {
      print("------------ cancel \(data)")
    }
    
    // 결제완료시 호출
    // 아이템 지급 등 데이터 동기화 로직을 수행합니다
    func onDone(data: [String: Any]) {
//        print("onDone")
        print("------------ done \(data)")
    }
    
    //결제창이 닫힐때 실행되는 부분
    func onClose() {
        print("--------------   close")
        Bootpay.dismiss()
    }
}



extension ViewController: BootpayRestProtocol {
   
   func readyBootpayBio() {
      getRestToken()
   }
 
   func getRestToken () {
      let restApplicationId = "5b8f6a4d396fa665fdc2b5ea"
      let privateKey = "n9jO7MxVFor3o//c9X5tdep95ZjdaiDvVB4h1B5cMHQ="
        
      BootpayRest.getRestToken(sendable: self, restApplicationId: restApplicationId, privateKey: privateKey)
    }
   
   func callbackRestToken(resData: [String: Any]) {
      if let data = resData["data"], let token  = (data as! [String: Any])["token"]  {
         
         let unique_user_id = String(Date().timeIntervalSinceReferenceDate) // 이 값이 user_id로, user별로 고유해야한다. 겹칠경우 등록된 결제수단에 대해 다른 사용자가 결제를 하는 대참사가 벌어질 수 있다.
         
         let user = BootpayUser()
         user.id = unique_user_id
         user.area = "서울"
         user.gender = 1
         user.email = "test1234@gmail.com"
         user.phone = "010-1234-4567"
         user.birth = "1988-06-10"
         user.username = "홍길동"
         
         if let json = user.toJSONString() {
            BootpayRest.getEasyPayUserToken(sendable: self, restToken: token as! String, user: json)
         }
      }
   }
   
   func callbackEasyCardUserToken(resData: [String: Any]) {
      
      if let data = resData["data"], let userToken  = (data as! [String: Any])["user_token"] {
        startBootpayBio(userToken as! String)
      }
   }
   
   func fingerBootpay(_ userToken: String) {
      
   }
   
   func startBootpayBio(_ userToken: String) {
    let bioPayload = BootpayBioPayload()
    bioPayload.pg = BootpayPG.NICEPAY
    bioPayload.names = ["플리츠레이어 카라숏원피스", "블랙 (COLOR)", "55 (SIZE)"]
//        bioPayload.application_id = "5b9f51264457636ab9a07cdd"
    bioPayload.application_id = "5b8f6a4d396fa665fdc2b5e9"
    bioPayload.order_id = String(Date().timeIntervalSinceReferenceDate)
    bioPayload.price = 1000
    bioPayload.name = "Touch ID 인증 결제 테스트"
//        bioPayload.quotas = [0,1,2,3,4,5]
    
    let extra = BootpayExtra()
    extra.quotas = [0,1,2,3,4,5]
    
    
    
    let p1 = BootpayBioPrice()
    let p2 = BootpayBioPrice()
    let p3 = BootpayBioPrice()
    
    p1.name = "상품가격"
    p1.price = 89000
    
    p2.name = "쿠폰적용"
    p2.price = -2500
    
    p3.name = "배송비"
    p3.price = 2500
    
    bioPayload.prices = [p1, p2, p3]
    bioPayload.user_token = userToken
    
    let item1 = BootpayItem().params {
        $0.item_name = "미\"키's 마우스" // 주문정보에 담길 상품명
        $0.qty = 1 // 해당 상품의 주문 수량
        $0.unique = "ITEM_CODE_MOUSE" // 해당 상품의 고유 키
        $0.price = 9000 // 상품의 가격
    }
    let item2 = BootpayItem().params {
        $0.item_name = "키보드" // 주문정보에 담길 상품명
        $0.qty = 1 // 해당 상품의 주문 수량
        $0.unique = "ITEM_CODE_KEYBOARD" // 해당 상품의 고유 키
        $0.price = 80000 // 상품의 가격
        $0.cat1 = "패션"
        $0.cat2 = "여\"성'상의"
        $0.cat3 = "블라우스"
    }
    var items = [BootpayItem]()
    items.append(item1)
    items.append(item2)
    
     // 구매자 정보
    let bootUser = BootpayUser()
     bootUser.params {
//            $0.username = "사용자 이름"
        $0.email = "user1234@gmail.com"
        $0.area = "서울" // 사용자 주소
        $0.addr = "서울시 동작구 상도로";
        $0.phone = "010-1234-4567"
     }
    
    
    Bootpay.requestBio(self, sendable: self, payload: bioPayload, user: bootUser, items: items, extra: extra)
   }
}
