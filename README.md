# MK Attendance Management System
## Version 4.1 - December 2024

A comprehensive attendance management solution with mobile (Flutter) and web interfaces.

## 🚀 **Quick Start**

### **Mobile App Installation:**
1. Download the latest APK from releases
2. Install on Android device (6.0+)
3. Login with provided credentials
4. Start marking attendance!

### **Web Access:**
- **URL**: https://mk-attendance.vercel.app
- **Login**: Use your system credentials
- **Features**: Full dashboard, reports, and management

## ✨ **Key Features**

### **📱 Mobile App:**
- ✅ **Attendance Marking**: Quick and easy attendance recording
- ✅ **QR Code Scanner**: Instant attendance via QR codes
- ✅ **Student Management**: Complete student information system
- ✅ **Class Organization**: Manage multiple classes efficiently
- ✅ **Dark/Light Themes**: Customizable appearance
- ✅ **Offline Support**: Limited functionality without internet

### **🌐 Web Interface:**
- ✅ **Dashboard**: Real-time attendance overview
- ✅ **Reports**: Detailed analytics and exports
- ✅ **User Management**: Admin panel for user control
- ✅ **Email Notifications**: Automated attendance alerts
- ✅ **Responsive Design**: Works on all devices

## 🆕 **What's New in v4.1**

- **Enhanced UI**: Dark blue text on light backgrounds for better readability
- **Streamlined Navigation**: Simplified More options menu
- **Fixed Navigation**: Resolved tab switching issues
- **Theme Improvements**: Better contrast and consistency
- **Performance**: Optimized app performance and stability

## 🏗️ **System Architecture**

### **Frontend:**
- **Mobile**: Flutter (Dart)
- **Web**: Next.js (React/TypeScript)
- **Styling**: Tailwind CSS, Material Design

### **Backend:**
- **API**: Next.js API Routes
- **Database**: PostgreSQL (Neon)
- **Authentication**: Custom JWT implementation
- **Email**: Nodemailer integration

### **Deployment:**
- **Web**: Vercel
- **Database**: Neon PostgreSQL
- **Mobile**: APK distribution

## 📋 **Requirements**

### **Mobile:**
- Android 6.0+ (API level 23)
- 100MB storage space
- Internet connection for sync

### **Web:**
- Modern browser (Chrome, Firefox, Safari, Edge)
- JavaScript enabled
- Stable internet connection

## 🔧 **Development Setup**

### **Prerequisites:**
- Node.js 18+
- Flutter SDK 3.0+
- PostgreSQL database

### **Installation:**
```bash
# Clone repository
git clone [repository-url]

# Install web dependencies
npm install

# Install Flutter dependencies
cd mk-attendance-flutter
flutter pub get

# Setup environment variables
cp .env.example .env.local
# Configure database and email settings

# Run web development server
npm run dev

# Run Flutter app
flutter run
```

## 📊 **Database Schema**

### **Core Tables:**
- **users**: System users and authentication
- **students**: Student information and enrollment
- **classes**: Class organization and management
- **attendance**: Attendance records and history
- **email_logs**: Email notification tracking

## 🔐 **Security Features**

- **JWT Authentication**: Secure user sessions
- **Role-based Access**: Admin, Manager, Teacher, User roles
- **Data Encryption**: Encrypted data transmission
- **Input Validation**: Comprehensive data validation
- **Session Management**: Automatic session timeout

## 📞 **Support & Documentation**

- **Help Guide**: See `HELP_AND_SUPPORT_v4.1.md`
- **Technical Docs**: Check `/docs` folder
- **API Reference**: Available in web interface
- **Support Email**: support@mkattendance.com

## 🤝 **Contributing**

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📄 **License**

This project is licensed under the MIT License - see the LICENSE file for details.

## 🏆 **Acknowledgments**

- Flutter team for excellent mobile framework
- Next.js team for powerful web framework
- Neon for reliable PostgreSQL hosting
- Vercel for seamless deployment

---

**Version**: 4.1.0  
**Last Updated**: December 18, 2024  
**Maintained by**: MK Development Team
