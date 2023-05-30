from crispy_forms.helper import FormHelper
from allauth.account.forms import LoginForm,SignupForm,ChangePasswordForm,ResetPasswordForm,ResetPasswordKeyForm,SetPasswordForm
from django.contrib.auth.forms import AuthenticationForm
from django import forms


class UserLoginForm(LoginForm):
    def __init__(self, *args, **kwargs):
        super(UserLoginForm, self).__init__(*args, **kwargs)
        self.helper = FormHelper(self)
        self.fields['login'].widget = forms.TextInput(attrs={'class': 'form-control mb-2','placeholder':'Enter Username','id':'username','tabindex':'1'})
        self.fields['password'].widget = forms.PasswordInput(attrs={'class': 'form-control mb-2 position-relative','placeholder':'Enter Password','id':'password','tabindex':'2'})
        self.fields['remember'].widget = forms.CheckboxInput(attrs={'class': 'form-check-input'})
class UserRegistrationForm(SignupForm):
    first_name = forms.CharField(widget=forms.TextInput(attrs={'class': 'form-control mb-2', 'placeholder': '성명 입력', 'id': 'first_name'}), label='성명')
    last_name = forms.CharField(widget=forms.TextInput(attrs={'class': 'form-control mb-2', 'placeholder': '부서 입력', 'id': 'last_name'}), label='부서')
#   division = forms.CharField(widget=forms.TextInput(attrs={'class': 'form-control mb-2', 'placeholder': '부서 입력', 'id': 'division'}), label='부서')

    def __init__(self, *args, **kwargs):
        super(UserRegistrationForm, self).__init__(*args, **kwargs)
        self.helper = FormHelper(self)
        self.fields['email'].widget = forms.EmailInput(attrs={'class': 'form-control mb-2','placeholder':'Enter Email','id':'email'})
        self.fields['email'].label="더마펌 Email"
        self.fields['username'].widget = forms.TextInput(attrs={'class': 'form-control mb-2','placeholder':'Enter Username','id':'username1'})
        self.fields['password1'].widget = forms.PasswordInput(attrs={'class': 'form-control mb-2','placeholder':'Enter Password','id':'password1'})
        self.fields['password2'].widget = forms.PasswordInput(attrs={'class': 'form-control mb-2','placeholder':'Enter Confirm Password','id':'password2'})
        self.fields['password2'].label="비밀번호 확인"
        # self.fields['first_name'].widget = forms.TextInput(attrs={'class': 'form-control mb-2','placeholder':'성함을 입력해주세요','id':'firstname'})
        # self.fields['last_name'].widget = forms.TextInput(attrs={'class': 'form-control mb-2','placeholder':'부서를 입력해주세요','id':'lastname'})



# class CustomSignupForm(SignupForm):
#     first_name = forms.TextInput(attrs={'class': 'form-control mb-2','placeholder':'성명을 입력해주세요','id':'first_name'})
#     last_name = forms.TextInput(attrs={'class': 'form-control mb-2','placeholder':'부서를 입력해주세요','id':'last_name'}) 
#     def save(self, request):
#         user = super(CustomSignupForm, self).save(request)
#         user.first_name = self.cleaned_data['first_name']
#         user.last_name = self.cleaned_data['last_name']
#         user.save()
#         return user        
        
class PasswordChangeForm(ChangePasswordForm):
      def __init__(self, *args, **kwargs):
        super(PasswordChangeForm, self).__init__(*args, **kwargs)
        self.helper = FormHelper(self)

        self.fields['oldpassword'].widget = forms.PasswordInput(attrs={'class': 'form-control mb-2','placeholder':'Enter currunt password','id':'password3'})
        self.fields['password1'].widget = forms.PasswordInput(attrs={'class': 'form-control mb-2','placeholder':'Enter new password','id':'password4'})
        self.fields['password2'].widget = forms.PasswordInput(attrs={'class': 'form-control mb-2','placeholder':'Enter confirm password','id':'password5'})
        self.fields['oldpassword'].label= "현재 비밀번호"
        self.fields['password2'].label="비밀번호 확인"
class PasswordResetForm(ResetPasswordForm):
      def __init__(self, *args, **kwargs):
        super(PasswordResetForm, self).__init__(*args, **kwargs)
        self.helper = FormHelper(self)

        self.fields['email'].widget = forms.EmailInput(attrs={'class': 'form-control mb-2','placeholder':' Enter Email','id':'email1'})
        self.fields['email'].label="Email"
class PasswordResetKeyForm(ResetPasswordKeyForm):
      def __init__(self, *args, **kwargs):
        super(PasswordResetKeyForm, self).__init__(*args, **kwargs)
        self.helper = FormHelper(self)
        self.fields['password1'].widget = forms.PasswordInput(attrs={'class': 'form-control mb-2','placeholder':'Enter new password','id':'password6'})
        self.fields['password2'].widget = forms.PasswordInput(attrs={'class': 'form-control mb-2','placeholder':'Enter confirm password','id':'password7'})
        self.fields['password2'].label="Confirm Password"
class PasswordSetForm(SetPasswordForm):
      def __init__(self, *args, **kwargs):
        super(PasswordSetForm, self).__init__(*args, **kwargs)
        self.helper = FormHelper(self)
        self.fields['password1'].widget = forms.PasswordInput(attrs={'class': 'form-control mb-2','placeholder':'Enter new password','id':'password8'})
        self.fields['password2'].widget = forms.PasswordInput(attrs={'class': 'form-control','placeholder':'Enter confirm password','id':'password9'})
        self.fields['password2'].label="Confirm Password"