//
//  ViewController.swift
//  Weather
//
//  Created by Nguyễn Giang on 16/12/2022.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    func getCurrentWeather(cityName: String) {
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?q=\(cityName)&units=metric&lang=kr&appid=0fb8463dce1de96897cba0b1eff08e18") else { return }
        // session 을 default session 으로 설정
        let session = URLSession(configuration: .default)
        // compression handler 로써 closure 매개 변수에 data(서버에서 응답 받은 data), response(HTTP header 나 상태 코드의 metaData), error(error 코드 반환)
        session.dataTask(with: url) { [weak self] data, response, error in
            // 응답받은 response (json data)를 weatherInfo struct 에 decoding 되게 하는 logic
            let successRange = (200..<300)
            guard let data = data, error == nil else { return }
            let decorder = JSONDecoder()
            // 응답받은 data 의 statusCode 가 200번대 (200 ~ 299) 일때
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {
                guard let weatherInfo =  try? decorder.decode(WeatherInfo.self, from: data) else { return }
                // debugPrint(weatherInfo)
                // 받아온 데이터를 UI 에 표시하기 위해서는 main thread 에서 작업을 진행 햐여 됩
                DispatchQueue.main.async {
                    self?.weatherStackView.isHidden = false
                    self?.configureView(weatherInfo: weatherInfo)
                    }
                } else { // status code 가 200 번대가 아니면 error 상태 이니까 error message 생성 logic
                    guard let errorMessage = try? decorder.decode(ErrorMessage.self, from: data) else { return }
                    // debugPrint(errorMessage)
                    // main thread 에서 alert 이 표시되게 해야됨
                    DispatchQueue.main.async {
                        self?.showAlert(message: errorMessage.message)
                    }
            }
        }.resume() // app 이 실행되게 함
        }
}

