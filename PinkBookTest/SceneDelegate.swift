//
//  SceneDelegate.swift
//  PinkBookTest
//
//  Created by mac on 2023/7/17.
//

import UIKit

//任务(执行的代码)
//1.同步执行任务(sync)-不具备开启多线程的能力
//2.异步执行任务(async)-具备开启多线程的能力

//队列(排队等待处理的任务)-FIFO(先进先出)-先排队的人先受理
//1.串行队列(Serial Dispatch Queue)-顺次执行队列中的任务
//2.并发队列(Concurrent Dispatch Queue)-同时执行队列中的任务

//串行队形同步执行
//串行队列异步执行
//并发队列同步执行
//并发队列异步执行

//3.默认代码为串行同步,网络请求为并发异步

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        //print("场景将要连接app")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        //print("场景与app已经断开")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        //print("场景已经变为活动状态")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        //print("场景将要变为非活动状态")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        //print("场景将要进入前台")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
        //print("场景已经进入后台")
    }


}

