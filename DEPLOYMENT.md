# EasyPanel Deployment Guide for FBMN-STATS

This guide provides instructions for deploying the FBMN-STATS application using EasyPanel's auto-deployment feature.

## Prerequisites

- EasyPanel instance running
- Docker and Docker Compose support
- Git repository access
- Domain name (optional but recommended)

## Quick Deployment

### Option 1: Auto-Deployment via EasyPanel UI

1. **Access EasyPanel Dashboard**
   - Log into your EasyPanel instance
   - Navigate to "Applications" or "Services"

2. **Create New Application**
   - Click "New Application" or "Add Service"
   - Select "Docker Compose" or "Git Repository"

3. **Configure Repository**
   - Repository URL: `https://github.com/Functional-Metabolomics-Lab/FBMN-STATS.git`
   - Branch: `main`
   - Auto-deploy: Enable

4. **Application Settings**
   - Name: `fbmn-stats`
   - Port: `8502`
   - Health Check Path: `/_stcore/health`

### Option 2: Manual Docker Compose Deployment

1. **Clone Repository**
   ```bash
   git clone https://github.com/Functional-Metabolomics-Lab/FBMN-STATS.git
   cd FBMN-STATS
   ```

2. **Deploy with Docker Compose**
   ```bash
   docker-compose up -d
   ```

3. **Verify Deployment**
   ```bash
   docker-compose ps
   docker-compose logs fbmn-stats
   ```

## Configuration

### Environment Variables

The following environment variables can be customized:

| Variable | Default | Description |
|----------|---------|-------------|
| `STREAMLIT_SERVER_PORT` | `8502` | Application port |
| `STREAMLIT_SERVER_ADDRESS` | `0.0.0.0` | Bind address |
| `STREAMLIT_SERVER_HEADLESS` | `true` | Run in headless mode |
| `STREAMLIT_SERVER_MAX_UPLOAD_SIZE` | `512` | Max upload size (MB) |
| `STREAMLIT_BROWSER_GATHER_USAGE_STATS` | `false` | Disable usage stats |

### Domain Configuration

1. **Update EasyPanel Configuration**
   - Edit `easypanel.yml`
   - Replace `fbmn-stats.yourdomain.com` with your actual domain

2. **SSL Configuration**
   - EasyPanel typically handles SSL automatically
   - Ensure your domain points to the EasyPanel instance

### Resource Limits

Default resource allocation:
- **Memory**: 2GB
- **CPU**: 1 core
- **Storage**: Persistent volume for user data

## File Structure

```
.
├── docker-compose.yml     # Main deployment configuration
├── Dockerfile             # Container build instructions
├── easypanel.yml          # EasyPanel-specific configuration
├── .dockerignore          # Files to exclude from build
├── DEPLOYMENT.md          # This file
└── requirements.txt       # Python dependencies
```

## Health Checks

The application includes built-in health checks:
- **Endpoint**: `/_stcore/health`
- **Interval**: 30 seconds
- **Timeout**: 10 seconds
- **Retries**: 3

## Volumes and Data Persistence

- **User Data**: `/app/data` (persistent volume)
- **Application Assets**: Read-only mounts for static files
- **Configuration**: `.streamlit/config.toml` mounted as read-only

## Monitoring and Logs

### View Logs
```bash
# Docker Compose
docker-compose logs -f fbmn-stats

# EasyPanel UI
# Navigate to Application > Logs in the dashboard
```

### Monitor Resources
```bash
# Check container stats
docker stats fbmn-stats-app

# Check health status
curl -f http://localhost:8502/_stcore/health
```

## Troubleshooting

### Common Issues

1. **Application Won't Start**
   - Check logs: `docker-compose logs fbmn-stats`
   - Check port availability: `netstat -tulpn | grep 8502`
   - Ensure sufficient resources are available

2. **Upload Issues**
   - Check `STREAMLIT_SERVER_MAX_UPLOAD_SIZE` setting
   - Verify `/app/data` volume permissions
   - Monitor disk space usage

3. **Performance Issues**
   - Increase memory allocation in `docker-compose.yml`
   - Monitor CPU usage and scale if needed
   - Check for memory leaks in application logs

4. **SSL/Domain Issues**
   - Verify DNS configuration
   - Check EasyPanel proxy settings
   - Ensure domain points to correct IP

### Debug Commands

```bash
# Enter container for debugging
docker-compose exec fbmn-stats bash

# Check application status
curl -I http://localhost:8502

# View detailed container info
docker inspect fbmn-stats-app

# Check network connectivity
docker-compose exec fbmn-stats ping google.com
```

## Scaling

### Horizontal Scaling
The application supports horizontal scaling through EasyPanel:
- Minimum instances: 1
- Maximum instances: 3
- Auto-scaling triggers: CPU > 80% or Memory > 80%

### Vertical Scaling
To increase resources, modify `docker-compose.yml`:
```yaml
services:
  fbmn-stats:
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: '2.0'
```

## Security Considerations

1. **File Uploads**: Limited to 512MB by default
2. **Network**: Application runs on internal network
3. **Data**: User uploads stored in persistent volume
4. **SSL**: Handled by EasyPanel reverse proxy

## Backup and Recovery

### Automated Backups
- Configured in `easypanel.yml`
- Daily backups at 2 AM
- 7-day retention policy

### Manual Backup
```bash
# Backup user data volume
docker run --rm -v fbmn-stats_app-data:/data -v $(pwd):/backup alpine tar czf /backup/fbmn-stats-data.tar.gz -C /data .

# Restore from backup
docker run --rm -v fbmn-stats_app-data:/data -v $(pwd):/backup alpine tar xzf /backup/fbmn-stats-data.tar.gz -C /data
```

## Updates and Maintenance

### Auto-Updates
EasyPanel can be configured for automatic updates when new commits are pushed to the repository.

### Manual Updates
```bash
# Pull latest changes
git pull origin main

# Rebuild and restart
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## Support

For issues related to:
- **Application**: [FBMN-STATS GitHub Issues](https://github.com/Functional-Metabolomics-Lab/FBMN-STATS/issues)
- **EasyPanel**: EasyPanel documentation and support
- **Docker**: Docker official documentation

## License

This deployment configuration is provided under the same license as the FBMN-STATS application.