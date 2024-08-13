//
//  LoginViewController.swift
//  Firebase-Chat-App
//
//  Created by Mehmet Ali ÇELEBİ on 31.07.2024.
//

import UIKit
import FBSDKLoginKit
import FirebaseAuth
import GoogleSignIn



protocol LoginViewDelegate: AnyObject {
    func didLogin()
}

class LoginViewController: UIViewController {
    let loginViewModel = LoginViewModel()
    
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .continue
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Email adress..."
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .white
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = .done
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.placeholder = "Password..."
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        textField.leftViewMode = .always
        textField.backgroundColor = .white
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    
    let loginButtonWithFB: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["public_profile", "email"]
        return button
    }()
    
    let loginButtonWithGoogle: GIDSignInButton = {
        let button = GIDSignInButton()
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginViewModel.view = self
        title = "Log In"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegisterButton))
        setupDelegates()
        addSubViews()
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginButtonWithGoogle.addTarget(self, action: #selector(signInWithGoogle), for: .touchUpInside)
    }
    
    @objc func signInWithGoogle() {
        loginViewModel.loginWithGoogle(withRepresenting: self)
    }
    
    func setupDelegates() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
        loginButtonWithFB.delegate = self
    }
    
    func addSubViews() {
        view.addSubview(scrollView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(emailTextField)
        scrollView.addSubview(passwordTextField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(loginButtonWithFB)
        scrollView.addSubview(loginButtonWithGoogle)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width / 3
        logoImageView.frame = CGRect(x: (scrollView.width - size) / 2, y: 50, width: size, height: size)
        emailTextField.frame = CGRect(x: 30, y: logoImageView.bottom + 10, width: scrollView.width - 60, height: 52)
        passwordTextField.frame = CGRect(x: 30, y: emailTextField.bottom + 10, width: scrollView.width - 60, height: 52)
        loginButton.frame = CGRect(x: 30, y: passwordTextField.bottom + 10, width: scrollView.width - 60, height: 52)
        loginButtonWithFB.frame = CGRect(x: 30, y: loginButton.bottom + 10, width: scrollView.width - 60, height: 52)
        loginButtonWithGoogle.frame = CGRect(x: 30, y: loginButtonWithFB.bottom + 10, width: scrollView.width - 60, height: 52)
    }
    
    @objc func loginButtonTapped() {
        view.endEditing(true)
        guard let email = emailTextField.text, let password = passwordTextField.text, !email.isEmpty, !password.isEmpty  else {
            alertUserLoginError()
            return
        }
        loginViewModel.login(withEmail: email, password: password)
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Error", message: "Email or password is not correct", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }
    
    @objc func didTapRegisterButton() {
        let registerVC = RegisterViewController()
        registerVC.title = "Create Account"
        navigationController?.pushViewController(registerVC, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            loginButtonTapped()
        default:
            break
        }
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: (Error)?) {
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with fb")
            return
        }      
        loginViewModel.loginWithFB(token: token)
    }
}

extension LoginViewController: LoginViewDelegate {
    func didLogin() {
        self.navigationController?.dismiss(animated: true)
    }
}
