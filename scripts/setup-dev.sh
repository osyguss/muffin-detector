#!/bin/bash
# Development Environment Setup Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Main setup function
main() {
    echo "🚀 Setting up Muffin vs Chihuahua Detector Development Environment"
    echo "=================================================================="
    
    # Check Python version
    print_status "Checking Python version..."
    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        print_success "Python $PYTHON_VERSION found"
        
        # Check if Python version is >= 3.10
        if python3 -c "import sys; exit(0 if sys.version_info >= (3, 10) else 1)"; then
            print_success "Python version is compatible (>= 3.10)"
        else
            print_error "Python 3.10 or higher is required"
            exit 1
        fi
    else
        print_error "Python 3 is not installed"
        exit 1
    fi
    
    # Check Git
    print_status "Checking Git..."
    if command_exists git; then
        print_success "Git is available"
    else
        print_error "Git is not installed"
        exit 1
    fi
    
    # Create virtual environment
    print_status "Creating virtual environment..."
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        print_success "Virtual environment created"
    else
        print_warning "Virtual environment already exists"
    fi
    
    # Activate virtual environment
    print_status "Activating virtual environment..."
    source venv/bin/activate
    
    # Upgrade pip
    print_status "Upgrading pip..."
    pip install --upgrade pip
    
    # Install dependencies
    print_status "Installing dependencies..."
    if [ -f "requirements-dev.txt" ]; then
        pip install -r requirements-dev.txt
        print_success "Development dependencies installed"
    else
        pip install -r requirements.txt
        print_warning "Only production dependencies installed (requirements-dev.txt not found)"
    fi
    
    # Setup pre-commit hooks
    print_status "Setting up pre-commit hooks..."
    if command_exists pre-commit; then
        pre-commit install
        pre-commit install --hook-type commit-msg
        print_success "Pre-commit hooks installed"
    else
        print_warning "Pre-commit not available, skipping hook installation"
    fi
    
    # Create necessary directories
    print_status "Creating project directories..."
    mkdir -p logs
    mkdir -p data/test_images
    mkdir -p docs
    print_success "Project directories created"
    
    # Check Docker (optional)
    print_status "Checking Docker availability..."
    if command_exists docker; then
        print_success "Docker is available"
        
        # Test Docker
        if docker --version >/dev/null 2>&1; then
            print_success "Docker is working"
        else
            print_warning "Docker is installed but not running"
        fi
    else
        print_warning "Docker is not installed (optional for local development)"
    fi
    
    # Check Make
    print_status "Checking Make availability..."
    if command_exists make; then
        print_success "Make is available"
        print_status "Available make targets:"
        make help 2>/dev/null || echo "  Run 'make help' to see available targets"
    else
        print_warning "Make is not installed (recommended for development)"
    fi
    
    # Run initial tests
    print_status "Running initial tests..."
    if python -m pytest tests/ --tb=short -q 2>/dev/null; then
        print_success "Initial tests passed"
    else
        print_warning "Some tests failed (this is normal for initial setup)"
    fi
    
    # Check code quality tools
    print_status "Checking code quality tools..."
    
    # Black
    if command_exists black; then
        print_success "Black (code formatter) is available"
    else
        print_warning "Black is not available"
    fi
    
    # Flake8
    if command_exists flake8; then
        print_success "Flake8 (linter) is available"
    else
        print_warning "Flake8 is not available"
    fi
    
    # MyPy
    if command_exists mypy; then
        print_success "MyPy (type checker) is available"
    else
        print_warning "MyPy is not available"
    fi
    
    echo ""
    echo "🎉 Development Environment Setup Complete!"
    echo "=========================================="
    echo ""
    echo "📋 Next Steps:"
    echo "1. Activate virtual environment: source venv/bin/activate"
    echo "2. Start development server: make dev"
    echo "3. Run tests: make test"
    echo "4. Check code quality: make quality"
    echo "5. Build Docker image: make docker-build"
    echo ""
    echo "📚 Useful Commands:"
    echo "• make help           - Show all available commands"
    echo "• make test-cov       - Run tests with coverage"
    echo "• make format         - Format code with Black and isort"
    echo "• make lint           - Run linting checks"
    echo "• make docker-test    - Test Docker container"
    echo "• make ci-local       - Simulate CI pipeline locally"
    echo ""
    echo "🔗 Documentation:"
    echo "• README.md           - Project overview"
    echo "• docs/CI_CD_PIPELINE.md - CI/CD documentation"
    echo ""
    print_success "Happy coding! 🧁🐕"
}

# Error handling
trap 'print_error "Setup failed at line $LINENO"' ERR

# Run main function
main "$@"
